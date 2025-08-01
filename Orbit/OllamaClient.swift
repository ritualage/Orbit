//
//  OllamaClient.swift
//  Orbit
//
//  Created by Patrick Moran on 8/1/25.
//


/*
- Optional: add a Stop button wired to client.stop().

Notes
- Ollama returns JSONL lines like {"response":"...","done":false}. The code concatenates response pieces and stops when done is true.
- If you see occasional decode errors, Ollama may emit keep-alive blank lines—those are skipped by the empty check.
- You can bump timeout intervals if you run very long generations.
*/
                                        
                                        
// OllamaClient.swift
import Foundation

final class OllamaClient: NSObject, ObservableObject {
    @Published var response: String = ""
    @Published var isRunning: Bool = false
    @Published var errorMessage: String?

    var baseURL = URL(string: "http://127.0.0.1:11434")!
    var modelName = "gemma3n:e4b"

    private var session: URLSession!
    private var buffer = Data()
    private var currentTask: URLSessionDataTask?

    override init() {
        super.init()
        let cfg = URLSessionConfiguration.default
        // Helps with long streams
        cfg.timeoutIntervalForRequest = 600
        cfg.timeoutIntervalForResource = 600
        session = URLSession(configuration: cfg, delegate: self, delegateQueue: nil)
    }

    func run(prompt: String) {
        // cancel any previous stream
        currentTask?.cancel()

        response = ""
        errorMessage = nil
        isRunning = true
        buffer.removeAll()

        var request = URLRequest(url: baseURL.appendingPathComponent("/api/generate"))
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": modelName,
            "prompt": prompt,
            "stream": true,
            "options": [
                "temperature": 0.6,
                "num_ctx": 4096
            ]
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let task = session.dataTask(with: request)
        currentTask = task
        task.resume()
    }

    func stop() {
        currentTask?.cancel()
        isRunning = false
    }
}

extension OllamaClient: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        // Append chunk and extract JSONL lines split by \n
        buffer.append(data)

        while let nlRange = buffer.firstRange(of: Data([0x0A])) { // newline
            let lineData = buffer.subdata(in: buffer.startIndex..<nlRange.lowerBound)
            buffer.removeSubrange(buffer.startIndex...nlRange.lowerBound)

            guard !lineData.isEmpty else { continue }

            if let obj = try? JSONSerialization.jsonObject(with: lineData) as? [String: Any] {
                let piece = obj["response"] as? String ?? ""
                DispatchQueue.main.async { self.response += piece }

                if let done = obj["done"] as? Bool, done == true {
                    DispatchQueue.main.async { self.isRunning = false }
                }
            } else {
                // If decoding fails, you can log the line for debugging
                // print("Bad line: $$String(data: lineData, encoding: .utf8) ?? "")")
            }
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        DispatchQueue.main.async {
            if let error = error as NSError?, error.code != NSURLErrorCancelled {
                self.errorMessage = error.localizedDescription
            }
            self.isRunning = false
        }
    }
}
