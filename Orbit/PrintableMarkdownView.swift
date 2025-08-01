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
    let pageWidth: CGFloat
    
    
    // Tunables
    private let readableWidth: CGFloat = 820     // max text column width
    private let bodySize: CGFloat = 14
    private let lineSpacing: CGFloat = 5
    private let blockSpacing: CGFloat = 14       // space between blocks/sections
    private let outerVertical: CGFloat = 36
    private let outerHorizontalMin: CGFloat = 36
    
    var body: some View {
        VStack(alignment: .leading, spacing: blockSpacing) {
            header
            if !inputs.isEmpty { inputsBlock }
            Divider().padding(.vertical, 4)
            
            // Markdown content
            Markdown(markdown)
                .markdownTheme(.gitHub)                  // safe across versions
                .markdownTextStyle { FontSize(bodySize) } // base size
                .frame(maxWidth: readableWidth, alignment: .topLeading)
                .lineSpacing(lineSpacing)                // breathing room between lines
                .padding(.vertical, 2)
            
            // Small spacer between major sections if needed
            Spacer(minLength: 0)
        }
        // Center the column with outer margins
        .padding(.vertical, outerVertical)
        .padding(.horizontal, max(outerHorizontalMin, (pageWidth - readableWidth) / 2))
        .frame(width: pageWidth, alignment: .top)
        .background(Color.white)
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Text(emoji).font(.system(size: 28))
                Text(title).font(.system(size: 22, weight: .semibold))
            }
        }
    }
    
    private var inputsBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Inputs").font(.headline)
            ForEach(inputs, id: \.0) { (k, v) in
                HStack(alignment: .top, spacing: 8) {
                    Text(k + ":").fontWeight(.semibold)
                    Text(v)
                }
                .font(.system(size: 13))
            }
        }
    }
}
//
//// Adds extra space between paragraphs using SwiftUI, compatible with older MarkdownUI
//private struct ParagraphSpacingModifier: ViewModifier {
//    let spacing: CGFloat
//    func body(content: Content) -> some View {
//        content
//            .markdownBlockStyle(.paragraph) { cfg in
//                cfg.label
//                    .padding(.bottom, spacing)
//            }
//            .markdownBlockStyle(.list) { cfg in
//                VStack(alignment: .leading, spacing: spacing) { cfg.label }
//            }
//            .markdownBlockStyle(.blockquote) { cfg in
//                cfg.label
//                    .padding(.vertical, spacing)
//            }
//            .markdownTableStyle { cfg in
//                // Roomier tables without TableCellPadding API
//                ScrollView(.horizontal, showsIndicators: false) {
//                    cfg.table
//                        .font(.system(size: 13))
//                        .padding(6)
//                }
//            }
//    }
//}
