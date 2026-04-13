#!/usr/bin/env swift
// Generates AppIcon.appiconset PNGs from the SF Symbol "cat.fill"
// rendered on a pastel pink → cream gradient background.
//
// Run from the repo root:
//   swift scripts/gen-icon.swift

import AppKit
import CoreGraphics

let outputDir = "Resources/Assets.xcassets/AppIcon.appiconset"
let fm = FileManager.default
try? fm.createDirectory(atPath: outputDir, withIntermediateDirectories: true)

struct IconSpec {
    let pixels: Int
    let filename: String
}

let specs: [IconSpec] = [
    .init(pixels: 16,   filename: "icon_16.png"),
    .init(pixels: 32,   filename: "icon_16@2x.png"),
    .init(pixels: 32,   filename: "icon_32.png"),
    .init(pixels: 64,   filename: "icon_32@2x.png"),
    .init(pixels: 128,  filename: "icon_128.png"),
    .init(pixels: 256,  filename: "icon_128@2x.png"),
    .init(pixels: 256,  filename: "icon_256.png"),
    .init(pixels: 512,  filename: "icon_256@2x.png"),
    .init(pixels: 512,  filename: "icon_512.png"),
    .init(pixels: 1024, filename: "icon_512@2x.png"),
]

func render(size pixels: Int) -> NSImage {
    let size = NSSize(width: pixels, height: pixels)
    let image = NSImage(size: size)
    image.lockFocus()
    defer { image.unlockFocus() }

    let rect = NSRect(origin: .zero, size: size)
    let cornerRadius = CGFloat(pixels) * 0.22
    let path = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
    path.addClip()

    // Background: pastel pink → cream
    let gradient = NSGradient(colors: [
        NSColor(srgbRed: 1.00, green: 0.78, blue: 0.82, alpha: 1.0),
        NSColor(srgbRed: 1.00, green: 0.94, blue: 0.86, alpha: 1.0),
    ])!
    gradient.draw(in: rect, angle: -90)

    // Cat glyph
    let symbolSize = CGFloat(pixels) * 0.62
    let config = NSImage.SymbolConfiguration(pointSize: symbolSize, weight: .bold)
        .applying(.init(paletteColors: [NSColor(srgbRed: 0.32, green: 0.20, blue: 0.24, alpha: 1.0)]))
    if let symbol = NSImage(systemSymbolName: "cat.fill", accessibilityDescription: nil)?
        .withSymbolConfiguration(config) {
        let s = symbol.size
        let drawRect = NSRect(
            x: (CGFloat(pixels) - s.width) / 2,
            y: (CGFloat(pixels) - s.height) / 2 - CGFloat(pixels) * 0.02,
            width: s.width,
            height: s.height
        )
        symbol.draw(in: drawRect)
    }

    return image
}

func writePNG(_ image: NSImage, to path: String) throws {
    guard let tiff = image.tiffRepresentation,
          let rep = NSBitmapImageRep(data: tiff),
          let png = rep.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "icon", code: 1, userInfo: [NSLocalizedDescriptionKey: "encode failed"])
    }
    try png.write(to: URL(fileURLWithPath: path))
}

for spec in specs {
    let image = render(size: spec.pixels)
    let path = "\(outputDir)/\(spec.filename)"
    try writePNG(image, to: path)
    print("✓ \(spec.filename) (\(spec.pixels)px)")
}

// Update Contents.json with filenames
let contents = """
{
  "images" : [
    { "filename" : "icon_16.png",     "idiom" : "mac", "scale" : "1x", "size" : "16x16" },
    { "filename" : "icon_16@2x.png",  "idiom" : "mac", "scale" : "2x", "size" : "16x16" },
    { "filename" : "icon_32.png",     "idiom" : "mac", "scale" : "1x", "size" : "32x32" },
    { "filename" : "icon_32@2x.png",  "idiom" : "mac", "scale" : "2x", "size" : "32x32" },
    { "filename" : "icon_128.png",    "idiom" : "mac", "scale" : "1x", "size" : "128x128" },
    { "filename" : "icon_128@2x.png", "idiom" : "mac", "scale" : "2x", "size" : "128x128" },
    { "filename" : "icon_256.png",    "idiom" : "mac", "scale" : "1x", "size" : "256x256" },
    { "filename" : "icon_256@2x.png", "idiom" : "mac", "scale" : "2x", "size" : "256x256" },
    { "filename" : "icon_512.png",    "idiom" : "mac", "scale" : "1x", "size" : "512x512" },
    { "filename" : "icon_512@2x.png", "idiom" : "mac", "scale" : "2x", "size" : "512x512" }
  ],
  "info" : { "author" : "xcode", "version" : 1 }
}
"""
try contents.write(toFile: "\(outputDir)/Contents.json", atomically: true, encoding: .utf8)
print("✓ Contents.json")
