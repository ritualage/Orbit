//
//  ContentView.swift
//  Orbit
//
//  Created by Patrick Moran on 8/1/25.
//

// ContentView.swift
import SwiftUI
import MarkdownUI

/*
 1) Keep promptPreview generation internally (so the button can run), but don’t render it. If you prefer, compute on-demand in run().
 
 2) Update the top Card to include the button.
 
 3) Remove the middle Card.
 
 4) Increase the minHeight of the results Card.
 */



/*
 Optional: compute the prompt on-demand
 - Remove promptPreview state and updatePreview().
 
 
 With these changes, users only see the inputs and a prominent Run button at the top, and the results area is doubled in height.
 */



struct ContentView: View {
    
    @State private var selected: ADHDTask = .dopamineMenu
    @State private var fieldValues: [String: String] = [:]
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
                        Text("Response")
                            .font(.headline)
                        ScrollView {
                            Markdown(client.response.isEmpty ? "Results will appear here." : client.response)
                                .markdownTheme(.gitHub) // nice default theme
                                .markdownTextStyle {
                                    FontSize(14)
                                }
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                                .padding(.trailing, 2) // avoids clipped right edge when scrolling
                        }
                        if let err = client.errorMessage {
                            Text(err).foregroundColor(.red).font(.footnote)
                        }
                    }
                    .frame(minHeight: 440) // roughly twice the earlier 220
                }
                
                Spacer()
            }
            //            .padding(20)
            .background(
                LinearGradient(colors: [.white, .accentCyan.opacity(0.15)], startPoint: .top, endPoint: .bottom)
            )
        }
    }
    
    private func run() {
        let prompt = selected.prompt(with: fieldValues)
        print(prompt)
        client.run(prompt: prompt)
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



