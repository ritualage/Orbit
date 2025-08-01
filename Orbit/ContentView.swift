//
//  ContentView.swift
//  Orbit
//
//  Created by Patrick Moran on 8/1/25.
//

// ContentView.swift
import SwiftUI
import MarkdownUI
import PDFKit

/*
 1) Keep promptPreview generation internally (so the button can run), but don’t render it. If you prefer, compute on-demand in run().
 
 2) Update the top Card to include the button.
 
 3) Remove the middle Card.
 
 4) Increase the minHeight of the results Card.
 */

/*
 Layout reminder
 Your outer HStack should contain:
 Left sidebar (existing)
 Main pane (existing, with Save button added)
 Right sidebar (new block above)
 
 
 Notes
 PDFs are stored in ~/Documents/Orbit; DB is in Application Support/Orbit/orbit.sqlite3.
 You can later add delete/rename by adding a context menu on each saved item and removing the file + row, then refreshing savedDocs.
 If you want fully styled PDFs that match the on-screen Markdown, switch to rendering HTML via WKWebView and print that to PDF; I kept this edition simple and reliable.
 */


/*
 Optional: compute the prompt on-demand
 - Remove promptPreview state and updatePreview().
 
 
 With these changes, users only see the inputs and a prominent Run button at the top, and the results area is doubled in height.
 */



struct ContentView: View {
    
    @State private var selected: ADHDTask = .dopamineMenu
    @State private var fieldValues: [String: String] = [:]
    @State private var savedDocs: [SavedDoc] = []
    
    @StateObject private var client = OllamaClient()
    
    var body: some View {
        HStack(spacing: 16) {
            // Sidebar
            VStack(alignment: .leading, spacing: 12) {
                Text("ADHD Toolkit")
                    .font(.system(size: 22, weight: .semibold))
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(ADHDTask.allCases) { task in
                            Button {
                                selected = task
                                fieldValues = [:]
                            } label: {
                                HStack {
                                    Text(task.rawValue)
                                        .font(.system(size: 14, weight: task == selected ? .semibold : .regular))
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                                .padding(10)
                                .background(task == selected ? Color.accentCyan.opacity(0.25) : Color.white)
                                .cornerRadius(10)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                Spacer()
            }
            .padding(16)
            .frame(width: 260)
            .background(Color.white)
            .overlay(Divider().frame(maxHeight: .infinity), alignment: .trailing)
            
            // Main pane
            VStack(alignment: .leading, spacing: 16) {
                Text(selected.rawValue)
                    .font(.system(size: 20, weight: .bold))
                
                // Top card: inputs + Run button
                Card {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(selected.fields) { field in
                            RoundedTextField(
                                title: field.label,
                                text: Binding(
                                    get: { fieldValues[field.key, default: ""] },
                                    set: { newValue in
                                        fieldValues[field.key] = newValue
                                        // optional: debounce internal prompt update
                                        // debouncer.schedule(after: 0.2) { updatePreview() }
                                    }
                                ),
                                multiline: field.isMultiline,
                                placeholder: field.placeholder
                            )
                        }
                        
                        HStack {
                            Button {
                                run()
                            } label: {
                                HStack {
                                    if client.isRunning { ProgressView().scaleEffect(0.7) }
                                    Text(client.isRunning ? "Running..." : "Run with Ollama")
                                }
                                .padding(.vertical, 8).padding(.horizontal, 12)
                                .background(Color.accentCyan)
                                .foregroundColor(.black)
                                .cornerRadius(10)
                            }
                            .disabled(client.isRunning)
                            
                            Spacer()
                            Text("Model \(client.modelName)")
                                .foregroundColor(.secondary)
                                .font(.footnote)
                        }
                        .padding(.top, 4)
                    }
                }
                
                // Results card (taller)
                Card {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Response").font(.headline)
                            Spacer()
                            Button {
                                saveCurrentResult()
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "square.and.arrow.down")
                                    Text("Save")
                                }
                            }
                            .disabled(client.response.isEmpty || client.isRunning)
                        }
                        
                        
                        ScrollView {
                            Markdown(client.response.isEmpty ? "Results will appear here." : client.response)
                                .markdownTheme(.gitHub)
                                .markdownTextStyle { FontSize(14) }
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                                .padding(.trailing, 2)
                        }
                        if let err = client.errorMessage {
                            Text(err).foregroundColor(.red).font(.footnote)
                        }
                    }
                    .frame(minHeight: 440)
                }
                
                
//                Card {
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("Response")
//                            .font(.headline)
//                        ScrollView {
//                            Markdown(client.response.isEmpty ? "Results will appear here." : client.response)
//                                .markdownTheme(.gitHub) // nice default theme
//                                .markdownTextStyle {
//                                    FontSize(14)
//                                }
//                                .frame(maxWidth: .infinity, alignment: .topLeading)
//                                .padding(.trailing, 2) // avoids clipped right edge when scrolling
//                        }
//                        if let err = client.errorMessage {
//                            Text(err).foregroundColor(.red).font(.footnote)
//                        }
//                    }
//                    .frame(minHeight: 440) // roughly twice the earlier 220
//                }
                
                Spacer()
            }
            
            // Right sidebar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Saved").font(.system(size: 16, weight: .semibold))
                    Spacer()
                    Button {
                        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        let folder = dir.appendingPathComponent("Orbit", isDirectory: true)
                        NSWorkspace.shared.open(folder)
                    } label: { Image(systemName: "folder") }
                        .buttonStyle(.plain)
                        .help("Open PDFs folder")
                }
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(savedDocs) { doc in
                            Button {
                                NSWorkspace.shared.open(URL(fileURLWithPath: doc.pdfPath))
                            } label: {
                                HStack(spacing: 10) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.white)
                                            .frame(width: 44, height: 56)
                                            .overlay(
                                                Text(doc.emoji).font(.system(size: 20))
                                            )
                                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                                    }
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(doc.title)
                                            .lineLimit(2)
                                            .font(.system(size: 12))
                                            .foregroundColor(.primary)
                                        Text(doc.date, style: .date)
                                            .font(.system(size: 10))
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "doc.text")
                                        .foregroundColor(.secondary)
                                }
                                .padding(6)
                                .background(Color.white.opacity(0.6))
                                .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                Spacer()
            }
            .padding(12)
            .frame(width: 260)
            .background(Color.white)
            .overlay(Divider().frame(maxHeight: .infinity), alignment: .leading)
            //            .padding(20)
//            .background(
//                LinearGradient(colors: [.white, .accentCyan.opacity(0.15)], startPoint: .top, endPoint: .bottom)
//            )
        }.onAppear { savedDocs = DB.shared.fetchAll() }
        
        
    }
    
    private func run() {
        let prompt = selected.prompt(with: fieldValues)
        print(prompt)
        client.run(prompt: prompt)
    }
    
    private func saveCurrentResult() {
        guard !client.response.isEmpty else { return }
        
        
        // Build inputs list for the PDF
        let inputs: [(String, String)] = selected.fields.map { field in
            (field.label, fieldValues[field.key, default: ""])
        }
        
        // Title and filename: emoji + task + first non-empty inputs
        let nonEmpty = inputs.map { $0.1 }.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        let suffix = nonEmpty.prefix(2).joined(separator: " · ")
        let docTitle = selected.displayTitle
        let fileBase = "\(selected.emoji)_\(docTitle)\(suffix.isEmpty ? "" : "_\(suffix)")"
        
        do {
            let url = try PDFGenerator.savePDFFromMarkdownUI(
                emoji: selected.emoji,
                title: selected.displayTitle,
                inputs: inputs,
                markdown: client.response,
                suggestedName: fileBase
            )
            
//            let url = try PDFGenerator.savePDF(
//                emoji: selected.emoji,
//                title: docTitle,
//                inputs: inputs,
//                markdown: client.response,
//                suggestedName: fileBase
//            )
            _ = DB.shared.insert(taskID: selected.idString,
                                 emoji: selected.emoji,
                                 title: suffix.isEmpty ? docTitle : "\(docTitle) — \(suffix)",
                                 pdfPath: url.path)
            savedDocs = DB.shared.fetchAll()
        } catch {
            print("PDF save failed: \(error)")
        }
    }
    
}

class Debouncer {
    private var work: DispatchWorkItem?
    func schedule(after seconds: Double, _ block: @escaping () -> Void) {
        work?.cancel()
        let w = DispatchWorkItem(block: block)
        work = w
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: w)
    }
}


#Preview {
    ContentView()
}



