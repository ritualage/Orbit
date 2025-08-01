//
//  ContentView.swift
//  Orbit
//
//  Created by Patrick Moran on 8/1/25.
//

// ContentView.swift
import SwiftUI

struct ContentView: View {
    @State private var selected: ADHDTask = .dopamineMenu
    @State private var fieldValues: [String: String] = [:]
    @State private var promptPreview: String = ""
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
                                updatePreview()
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

                Card {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(selected.fields) { field in
                            RoundedTextField(
                                title: field.label,
                                text: Binding(
                                    get: { fieldValues[field.key, default: ""] },
                                    set: { fieldValues[field.key] = $0; updatePreview() }
                                ),
                                multiline: field.isMultiline,
                                placeholder: field.placeholder
                            )
                        }
                    }
                }

                Card {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Prompt preview")
                                .font(.headline)
                            Spacer()
                            Button {
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(promptPreview, forType: .string)
                            } label: {
                                Text("Copy")
                            }
                        }
                        ScrollView {
                            Text(promptPreview.isEmpty ? "Fill in the fields to see the prompt..." : promptPreview)
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .topLeading)
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
                            .disabled(client.isRunning || promptPreview.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            Spacer()
                            Text("Model: $$client.modelName)").foregroundColor(.secondary).font(.footnote)
                        }
                    }
                }

                Card {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Response")
                            .font(.headline)
                        ScrollView {
                            Text(client.response.isEmpty ? "Results will appear here." : client.response)
                                .font(.system(size: 14))
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                        }
                        if let err = client.errorMessage {
                            Text(err).foregroundColor(.red).font(.footnote)
                        }
                    }
                    .frame(minHeight: 220)
                }

                Spacer()
            }
            .padding(20)
        }
        .background(
            LinearGradient(colors: [.white, .accentCyan.opacity(0.15)], startPoint: .top, endPoint: .bottom)
        )
        .onAppear { updatePreview() }
    }

    private func updatePreview() {
        promptPreview = selected.prompt(with: fieldValues)
    }

    private func run() {
        client.run(prompt: promptPreview)
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



