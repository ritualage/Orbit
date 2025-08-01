//
//  Styling.swift
//  Orbit
//
//  Created by Patrick Moran on 8/1/25.
//


// Swift 5.9 lacks bytesTask on older targets; to keep it simple if needed, you can instead poll DataTask and parse incrementally or set stream: false and get full output. If streaming complicates your target, swap the bytesTask with dataTask and set stream: false.

// Styling.swift
import SwiftUI
import Foundation

extension Color {

    static let card = Color(NSColor.windowBackgroundColor).opacity(0.9)
    static let accentCyan = Color(red: 0.61, green: 0.87, blue: 0.92)
}

struct Card<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        content
            .padding(16)
            .background(.white)
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
    }
}

struct RoundedTextField: View {
    let title: String
    @Binding var text: String
    var multiline = false
    var placeholder = ""
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.headline)
            if multiline {
                TextEditor(text: $text)
                    .font(.body)
                    .frame(minHeight: 80)
                    .padding(10)
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.15)))
            } else {
                TextField(placeholder, text: $text)
                    .textFieldStyle(.plain)
                    .padding(10)
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.15)))
            }
        }
    }
}
