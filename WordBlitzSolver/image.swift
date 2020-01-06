//
//  image.swift
//  WordBlitzSolver
//
//  Created by Max Chuquimia on 6/1/20.
//  Copyright © 2020 Max Chuquimia. All rights reserved.
//

import Cocoa

func trim(image: NSImage, rect: CGRect) -> NSImage {
    let result = NSImage(size: rect.size)
    result.lockFocus()

    let destRect = CGRect(origin: .zero, size: result.size)
    image.draw(in: destRect, from: rect, operation: .copy, fraction: 1.0)

    result.unlockFocus()
    return result
}

private let colours: [NSColor] = [
    .init(red:0.85, green:0.00, blue:0.00, alpha:0.5),
    .init(red:0.85, green:0.41, blue:0.00, alpha:0.5),
    .init(red:0.85, green:0.71, blue:0.00, alpha:0.5),
    .init(red:0.48, green:0.85, blue:0.00, alpha:0.5),
    .init(red:0.00, green:0.39, blue:0.85, alpha:0.5), // blue
    .init(red:0.37, green:0.00, blue:0.85, alpha:0.5),
    .init(red:0.73, green:0.00, blue:0.85, alpha:0.5),
    .init(red:0.25, green:0.16, blue:0.30, alpha:0.5),
    .init(red:0.84, green:0.84, blue:0.84, alpha:0.5),
]

func annotate(board: NSImage, with trail: [Loc]) -> NSImage {
    let annotatedImage = NSImage(size: board.size)
    let imageRect = CGRect(x: 0, y: 0, width: board.size.width, height: board.size.height)
    let rep:NSBitmapImageRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(board.size.width), pixelsHigh: Int(board.size.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: NSColorSpaceName.calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    annotatedImage.addRepresentation(rep)
    annotatedImage.lockFocus()
    board.draw(in: imageRect)

    for (idx, loc) in trail.enumerated() {
        let colour = colours[idx]
        let point = cropMultipliers[loc.y][loc.x]


        let circleRect = CGRect(x: board.size.width * point.0, y: board.size.height * point.1, width: board.size.width * 0.25 , height: board.size.height * 0.25)
        let path = NSBezierPath(ovalIn: circleRect)
        colour.setFill()
        path.fill()


        let text = NSAttributedString(string: "\(idx + 1)", attributes: [
            .font: NSFont.systemFont(ofSize: 18, weight: .black),
            .foregroundColor: NSColor.black
        ])
        text.draw(at: NSPoint(x: circleRect.midX - 9, y: circleRect.minY + 8))
    }

    annotatedImage.unlockFocus()
    return annotatedImage
}
