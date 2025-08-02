//
//  Buttons.swift
//  Orbit
//
//  Created by Patrick Moran on 8/1/25.
//
import SwiftUI

struct RunButton: View {
    let isRunning: Bool
    let action: () -> Void
    
    
    // Set explicit size so layout stays stable
    private let buttonHeight: CGFloat = 32
    private let horizontalPadding: CGFloat = 14
    private let minWidth: CGFloat = 160 // wide enough for longest label
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isRunning {
                    ProgressView()
                        .scaleEffect(0.7)
                }
                Text(isRunning ? "Running…" : "Run with Ollama")
                    .font(.system(size: 14, weight: .semibold))
            }
            .frame(minWidth: minWidth)
            .frame(height: buttonHeight)
            .contentShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain) // avoid default bordered style outline
        .padding(.vertical, 0)
        .padding(.horizontal, 0)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.accentCyan) // your custom cyan
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.clear, lineWidth: 0) // no odd outline
        )
        .foregroundColor(.black)
    }
}

struct SaveButton: View {
    let isEnabled: Bool
    let action: () -> Void
    
    
    private let buttonHeight: CGFloat = 32
    private let minWidth: CGFloat = 120  // adjust if you want it wider to match Run
    private let cornerRadius: CGFloat = 10
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "square.and.arrow.down")
                Text("Save")
                    .font(.system(size: 14, weight: .semibold))
            }
            .frame(minWidth: minWidth)
            .frame(height: buttonHeight)
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
        .buttonStyle(.plain)
        .foregroundColor(.black)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(isEnabled ? Color.green : Color.green.opacity(0.25))
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.clear, lineWidth: 0)
        )
        .disabled(!isEnabled)
    }
}
