//
//  PrintableMarkdownView.swift
//  Orbit
//
//  Created by Patrick Moran on 8/1/25.
//

import SwiftUI
import MarkdownUI
struct PrintableMarkdownView: View {
    let emoji: String
    let title: String
    let inputs: [(String, String)]
    let markdown: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Text(emoji).font(.system(size: 28))
                Text(title).font(.system(size: 22, weight: .bold))
            }
            if !inputs.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Inputs").font(.headline)
                    ForEach(inputs, id: \.0) { (k, v) in
                        HStack(alignment: .top, spacing: 6) {
                            Text(k + ":").fontWeight(.semibold)
                            Text(v)
                        }
                        .font(.system(size: 12))
                    }
                }
            }
            Divider().padding(.vertical, 4)
            Markdown(markdown)
                .markdownTheme(.gitHub)
                .markdownTextStyle { FontSize(13) }
                .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .padding(24)
        .frame(width: 612) // Letter width at 72dpi
    }
}
