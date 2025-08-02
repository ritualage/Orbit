//
//  PDFGenerator.swift
//  Orbit
//
//  Created by Patrick Moran on 8/1/25.
//


import SwiftUI
import Foundation
import PDFKit

enum PDFGenerator {
    static func savePDFFromMarkdownUI(emoji: String,
                                      title: String,
                                      inputs: [(String, String)],
                                      markdown: String,
                                      suggestedName: String) throws -> URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let folder = dir.appendingPathComponent("Orbit", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let safe = suggestedName.replacingOccurrences(of: "[^a-zA-Z0-9_-]+", with: "_", options: .regularExpression)
        let url = folder.appendingPathComponent("\(safe).pdf")
        
        
        // Page width remains e.g. 612 pts; height will be the content’s ideal height
        //let pageWidth: CGFloat = 612
        let pageWidth: CGFloat = 792 // Letter landscape width (11" * 72)
        
        let view = PrintableMarkdownView(emoji: emoji, title: title, inputs: inputs, markdown: markdown, pageWidth: pageWidth)
        let hosting = NSHostingView(rootView: view)
        
        // First set a provisional width, tiny height
        hosting.frame = NSRect(x: 0, y: 0, width: pageWidth, height: 10)
        
        // Ask SwiftUI for the ideal height at that width
        let idealSize = hosting.fittingSize
        let totalHeight = max(idealSize.height, 10)
        
        // Resize to exact content height
        hosting.frame.size.height = totalHeight
        
        // Capture one tall page
        let tallData = hosting.dataWithPDF(inside: NSRect(x: 0, y: 0, width: pageWidth, height: totalHeight))
        
        try tallData.write(to: url, options: [.atomic])
        return url
    }
    
    // Top-down pagination so page 1 starts with the beginning of your content
    static func paginateTopDown(_ data: Data, pageSize: CGSize) -> Data? {
        guard let srcDoc = PDFDocument(data: data),
              let firstPage = srcDoc.page(at: 0),
              let cgPage = firstPage.pageRef else { return nil }
        
        let srcBounds = firstPage.bounds(for: .mediaBox)
        let totalHeight = srcBounds.height
        
        let outDoc = PDFDocument()
        var pageIndex = 0
        var yOffset: CGFloat = 0
        
        while yOffset < totalHeight {
            let pdfData = NSMutableData()
            var mediaBox = CGRect(origin: .zero, size: pageSize)
            guard let consumer = CGDataConsumer(data: pdfData as CFMutableData),
                  let ctx = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else { break }
            
            ctx.beginPDFPage(nil)
            ctx.saveGState()
            
            // Translate so that we cut from the TOP
            // PDF origin is bottom-left; the top slice begins at (totalHeight - pageHeight)
            let sliceOriginY = max(totalHeight - pageSize.height - yOffset, 0)
            ctx.translateBy(x: 0, y: -sliceOriginY)
            
            ctx.drawPDFPage(cgPage)
            ctx.restoreGState()
            ctx.endPDFPage()
            ctx.closePDF()
            
            if let piece = PDFDocument(data: pdfData as Data),
               let piecePage = piece.page(at: 0) {
                outDoc.insert(piecePage, at: pageIndex)
                pageIndex += 1
            }
            yOffset += pageSize.height
        }
        
        return outDoc.dataRepresentation()
    }
}

struct PDFContentView: View {
    let emoji: String
    let title: String
    let inputs: [(String, String)]
    let markdownPlainText: String
    
    
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
            Text(markdownPlainText)
                .font(.system(size: 12))
                .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .padding(24)
        .frame(width: 792) // Letter width at 72dpi
    }
}
