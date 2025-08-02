//
//  OrbitApp.swift
//  Orbit
//
//  Created by Patrick Moran on 8/1/25.
//

import SwiftUI

@main
struct OrbitApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.colorScheme, .light)
        }
#if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unifiedCompact)
#endif
        .commands {
            CommandGroup(after: .textEditing) {
                Button("Run with Ollama") {
                    // Access a singleton, environment object, or post a notification to trigger run()
                    NotificationCenter.default.post(name: .runWithOllamaShortcut, object: nil)
                }
                .keyboardShortcut(.return, modifiers: [.command])
            }
        }
    }
}

extension Notification.Name {
    static let runWithOllamaShortcut = Notification.Name("runWithOllamaShortcut")
}

