//
//  FileListView.swift
//  Orbit
//
//  Created by Patrick Moran on 8/2/25.
//


import SwiftUI

struct FileListView: View {
    @State private var files: [URL] = []
    @State private var showDeleteConfirm = false
    @State private var pendingDeleteURL: URL?
    
    
    var body: some View {
        List(files, id: \.self) { fileURL in
            HStack {
                Text(fileURL.lastPathComponent)
                Spacer()
            }
            .contextMenu {
                Button(role: .destructive) {
                    pendingDeleteURL = fileURL
                    showDeleteConfirm = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .onAppear { loadFiles() }
        .confirmationDialog(
            "Delete this file?",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let url = pendingDeleteURL {
                    deleteFile(at: url)
                }
                pendingDeleteURL = nil
            }
            Button("Cancel", role: .cancel) {
                pendingDeleteURL = nil
            }
        } message: {
            if let url = pendingDeleteURL {
                Text("“\(url.lastPathComponent)” will be moved to the Trash.")
            } else {
                Text("This will move the file to the Trash.")
            }
        }
    }
    
    private func loadFiles() {
        // Load your URLs here
        // files = ...
    }
    
    private func refreshList() {
        loadFiles()
    }
    
    private func deleteFile(at url: URL) {
        do {
            try FileManager.default.trashItem(at: url, resultingItemURL: nil)
            refreshList()
        } catch {
            // Optional: show an error toast/alert
            print("Failed to trash item: \( error)")
        }
    }
}
