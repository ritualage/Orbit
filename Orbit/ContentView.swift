//
//  ContentView.swift
//  Orbit
//
//  Created by Patrick Moran on 8/1/25.
//

import SwiftUI
import MarkdownUI
import PDFKit
import AppKit
import QuickLookUI

final class SinglePreviewDataSource: NSObject, QLPreviewPanelDataSource {
    private let url: URL
    init(url: URL) { self.url = url }
    func numberOfPreviewItems(in panel: QLPreviewPanel!) -> Int { 1 }
    func previewPanel(_ panel: QLPreviewPanel!, previewItemAt index: Int) -> QLPreviewItem {
        url as QLPreviewItem
    }
}

struct ContentView: View {
    
    
    @State private var selected: ADHDTask = .dopamineMenu
    @State private var fieldValues: [String: String] = [:]
    @State private var savedDocs: [SavedDoc] = []
    @State private var quickLookDataSource: SinglePreviewDataSource?
    
    // delete confirmation
    @State private var showDeleteConfirm = false
    @State private var pendingDeleteURL: URL?
    @State private var pendingDeleteDBID: Int64?
    
    @StateObject private var client = OllamaClient()
    @FocusState private var focusedFieldKey: String?
    
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
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack(spacing: 8) {
                                        Text(task.emoji)
                                        Text(task.displayTitle)
                                            .font(.system(size: 14, weight: task == selected ? .semibold : .regular))
                                            .foregroundColor(.primary)
                                        Spacer()
                                    }
                                    Text(task.description)
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                        .fixedSize(horizontal: false, vertical: true) // allow wrap, no clipping
                                        .lineLimit(3) // or remove to allow full wrap
                                }
                                .padding(.vertical, 10) // more vertical space inside each row
                                .padding(.horizontal, 10)
                                .background(task == selected ? Color.accentCyan.opacity(0.25) : Color.white)
                                .cornerRadius(10)
                            }
                            .buttonStyle(.plain)
                            
                            // Extra space between items
                            .padding(.bottom, 6)
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
                VStack(alignment: .leading, spacing: 6) {
                    Text(selected.rawValue)
                        .font(.system(size: 20, weight: .bold))
                }
                
                // Top card: inputs + Run button
                Card {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.secondary)
                            Text(selected.panelHelp)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        .padding(.bottom, 4)
                        ForEach(selected.fields) { field in
                            RoundedTextField(
                                title: field.label,
                                text: Binding(
                                    get: { fieldValues[field.key, default: ""] },
                                    set: { newValue in
                                        fieldValues[field.key] = newValue
                                    }
                                ),
                                multiline: field.isMultiline,
                                placeholder: field.placeholder
                            )
                        }
                        
                        HStack {
                            RunButton(isRunning: client.isRunning) {
                                if !client.isRunning { run() }
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
                            SaveButton(
                                isEnabled: !(client.response.isEmpty || client.isRunning)
                            ) {
                                saveCurrentResult()
                            }
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
                            let fileURL = URL(fileURLWithPath: doc.pdfPath)
                            
                            Button {
                                NSWorkspace.shared.open(fileURL)
                            } label: {
                                HStack(spacing: 10) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.white)
                                            .frame(width: 44, height: 56)
                                            .overlay(Text(doc.emoji).font(.system(size: 20)))
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
                            .contextMenu {
                                Button("Open") { NSWorkspace.shared.open(fileURL) }
                                Button("Reveal in Finder") {
                                    NSWorkspace.shared.activateFileViewerSelecting([fileURL])
                                }
                                Button("Share…") { shareFile(fileURL) }
                                Button("Quick Look") { quickLook(url: fileURL) }
                                Divider()
                                Button(role: .destructive) {
                                    pendingDeleteURL = fileURL
                                    pendingDeleteDBID = doc.id
                                    showDeleteConfirm = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                Spacer()
            }
            .padding(12)
            .frame(width: 260)
            .background(Color.white)
            .overlay(Divider().frame(maxHeight: .infinity), alignment: .leading)
        }
        .confirmationDialog(
            "Delete this file?",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let url = pendingDeleteURL, let id = pendingDeleteDBID {
                    deleteToTrash(at: url, dbID: id)
                }
                clearPendingDelete()
            }
            Button("Cancel", role: .cancel) {
                clearPendingDelete()
            }
        } message: {
            if let url = pendingDeleteURL {
                Text("“\(url.lastPathComponent)” will be moved to the Trash.")
            } else {
                Text("This will move the file to the Trash.")
            }
        }
        .onAppear { savedDocs = DB.shared.fetchAll() }
        .onReceive(NotificationCenter.default.publisher(for: .runWithOllamaShortcut)) { _ in
            if !client.isRunning { run() }
        }
    }
    
    private func clearPendingDelete() {
        pendingDeleteURL = nil
        pendingDeleteDBID = nil
    }
    
    private func deleteToTrash(at url: URL, dbID: Int64) {
        do {
            try FileManager.default.trashItem(at: url, resultingItemURL: nil)
            DB.shared.delete(id: dbID)
            savedDocs = DB.shared.fetchAll()
        } catch {
            let alert = NSAlert(error: error)
            alert.runModal()
        }
    }
    
    private func run() {
        let prompt = selected.prompt(with: fieldValues)
        print(prompt)
        client.run(prompt: prompt)
    }
    
    private func saveCurrentResult() {
        guard !client.response.isEmpty else { return }
        
        let inputs: [(String, String)] = selected.fields.map { field in
            (field.label, fieldValues[field.key, default: ""])
        }
        
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
            _ = DB.shared.insert(taskID: selected.idString,
                                 emoji: selected.emoji,
                                 title: suffix.isEmpty ? docTitle : "\(docTitle) — \(suffix)",
                                 pdfPath: url.path)
            savedDocs = DB.shared.fetchAll()
        } catch {
            print("PDF save failed: \(error)")
        }
    }
    
    private func deletePDF(at url: URL, dbID: Int64) {
        do {
            try FileManager.default.removeItem(at: url)
            DB.shared.delete(id: dbID)
            savedDocs = DB.shared.fetchAll()
        } catch {
            let alert = NSAlert(error: error)
            alert.runModal()
        }
    }
    
    private func quickLook(url: URL) {
        guard let panel = QLPreviewPanel.shared() else { return }
        let ds = SinglePreviewDataSource(url: url)
        quickLookDataSource = ds
        panel.dataSource = ds
        if panel.isVisible {
            panel.reloadData()
        } else {
            panel.makeKeyAndOrderFront(nil)
        }
    }
    
    private func keywordFileBase(for task: ADHDTask, fields: [ADHDTask.Field], values: [String: String]) -> String {
        // Collect non-empty user inputs in field order
        let nonEmptyValues = fields
            .map { values[$0.key, default: ""].trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        
        // Build a short keyword slug from first 2 inputs
        let keywordPart = nonEmptyValues
            .prefix(2)
            .joined(separator: " · ")
        
        // Fallback: if no inputs, use date to avoid collisions
        if keywordPart.isEmpty {
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd_HH-mm"
            return "\(task.emoji)_\(df.string(from: Date()))"
        }
        
        return "\(task.emoji)_\(keywordPart)"
    }
}

extension View {
    func shareFile(_ url: URL) {
        let picker = NSSharingServicePicker(items: [url])
        if let window = NSApp.keyWindow, let view = window.contentView {
            picker.show(relativeTo: .zero, of: view, preferredEdge: .minY)
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
