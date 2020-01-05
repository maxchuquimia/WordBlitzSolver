//
//  main.swift
//  WordBlitzSolver
//
//  Created by Max Chuquimia on 5/1/20.
//  Copyright © 2020 Max Chuquimia. All rights reserved.
//

import Foundation
import Cocoa
import ShellSwift
import CoreGraphics
import Vision

typealias Loc = (x: Int, y: Int, OCRResult)
typealias Matrix<T> = [[T]]

NSPasteboard.general.clearContents()

func trim(image: NSImage, rect: CGRect) -> NSImage {
    let result = NSImage(size: rect.size)
    result.lockFocus()

    let destRect = CGRect(origin: .zero, size: result.size)
    image.draw(in: destRect, from: rect, operation: .copy, fraction: 1.0)

    result.unlockFocus()
    return result
}

var matrix: Matrix<Loc> = []

print("Place Quicktime against right side of screen, full height.\nThen, Command+Control+Shift+3.")

while true {

    if let p = NSPasteboard.general.readObjects(forClasses: [NSImage.self], options: nil) as? [NSImage], let image = p.first {
        print(p)

        // hardcoded position of 4x4 square on entire screen (y-increase from bottom)
        let image = trim(image: image, rect: CGRect(x: 1231, y: 180, width: 422, height: 422))

        let cropMultipliers: Matrix<(CGFloat, CGFloat)> = [
            [(0.0, 0.75), (0.25, 0.75), (0.50, 0.75), (0.75, 0.75)],
            [(0.0, 0.50), (0.25, 0.50), (0.50, 0.50), (0.75, 0.50)],
            [(0.0, 0.25), (0.25, 0.25), (0.50, 0.25), (0.75, 0.25)],
            [(0.0, 0.00), (0.25, 0.00), (0.50, 0.00), (0.75, 0.00)]
        ]

        matrix = cropMultipliers
            .enumerated()
            .map { (arg) -> [Loc] in
                let (idx, row) = arg

                return row.enumerated()
                    .map { arg in
                        let (idx2, point) = arg

                        let rect = CGRect(x: image.size.width * point.0, y: image.size.height * point.1, width: image.size.width * 0.25 , height: image.size.height * 0.25)

                        let cropped = trim(image: image, rect: rect).cgImage(forProposedRect: nil, context: nil, hints: nil)!
                        var results = ocr(on: cropped)

                        if results.letter.isEmpty {
                            results.letter = ocr(on: cropped, minimumTextHeight: 0.2).letter // try look for bigger letters

                            // It seems Vision has trouble finding I's and Z's 😱
                            if results.letter.isEmpty {
                                print("Finding even bigger letters")
                                // Will break everything if this is actually a Z
                                results.letter = "I"// ocr(on: cropped, minimumTextHeight: 0.3).letter // try look for bigger letters
                            }
                        }

                        return (idx, idx2, results)
                }
        }

        print("Found", matrix)
        break
    }

    Thread.sleep(forTimeInterval: 0.2)
}


let file = try! cat("/Users/Max.Chuquimia/Desktop/personal/WordBlitzSolver/WordBlitzSolver/words.txt") | String.new()

var allWords = Set(file.components(separatedBy: "\r\n"))

extension String {
    // https://stackoverflow.com/a/47566321/1153630
    func separate(every: Int, with separator: String) -> String {
        return String(stride(from: 0, to: Array(self).count, by: every).map {
            Array(Array(self)[$0..<min($0 + every, Array(self).count)])
        }.joined(separator: separator))
    }
}


let MATRIX_BOUNDS = 3 // Max index of matric cols and rows


print(matrix.map({ (row) -> String in
    row.map({ $0.2.letter }).joined() + "\n"
}))


func moves(from loc: Loc, in matrix: Matrix<Loc>, excluding locsToExclude: [Loc] = []) -> [Loc] {
    var moves: [Loc] = []
    var locsToExclude = locsToExclude
    locsToExclude.append(loc)

    // Rightwards
    if loc.x < MATRIX_BOUNDS {
        var newLoc = loc
        newLoc.x += 1
        moves.append(newLoc)

        // Diagonal right up
        if loc.y > 0 {
            var newLoc = loc
            newLoc.x += 1
            newLoc.y -= 1
            moves.append(newLoc)
        }

        // Diagonal right down
        if loc.y < MATRIX_BOUNDS {
            var newLoc = loc
            newLoc.x += 1
            newLoc.y += 1
            moves.append(newLoc)
        }
    }

    // Leftwards
    if loc.x > 0 {
        var newLoc = loc
        newLoc.x -= 1
        moves.append(newLoc)

        // Diagonal left up
        if loc.y > 0 {
            var newLoc = loc
            newLoc.x -= 1
            newLoc.y -= 1
            moves.append(newLoc)
        }

        // Diagonal left down
        if loc.y < MATRIX_BOUNDS {
            var newLoc = loc
            newLoc.x -= 1
            newLoc.y += 1
            moves.append(newLoc)
        }
    }

    // Downwards
    if loc.y < MATRIX_BOUNDS {
        var newLoc = loc
        newLoc.y += 1
        moves.append(newLoc)
    }

    // Upwards
    if loc.y > 0 {
        var newLoc = loc
        newLoc.y -= 1
        moves.append(newLoc)
    }

    return moves.filter { newLoc in
        !locsToExclude.contains(where: { $0.x == newLoc.x && $0.y == newLoc.y })
    }
}

//print(moves(from: (3, 3), in: matrix))

var OUTPUT: Set<String> = []

func letterMultiplier(_ multipier: String?) -> Int {
    if multipier == "2L" { return 2 }
    if multipier == "3L" { return 3 }
    if multipier == "4L" { return 4 }
    return 1
}

func wordMultiplier(_ multipier: String?) -> Int {
    if multipier == "2W" { return 2 }
    if multipier == "3W" { return 3 }
    if multipier == "4W" { return 4 }
    return 1
}

func p(word: String, loc: Loc, trail: [Loc]) {
    let possibleMoves = moves(from: loc, in: matrix, excluding: trail)

    for possibleMove in possibleMoves {
        var tl = matrix[possibleMove.y][possibleMove.x]
        tl.x = possibleMove.x
        tl.y = possibleMove.y
        let newTrail = trail + [tl]
        let word2 = word + tl.2.letter

        // Skip short words because the lookups here could be expensive
        if word2.count > 3 && allWords.contains(word2) {
            //print(word2)

            var baseScore = newTrail.map { $0.2.score * letterMultiplier($0.2.multiplier) }.reduce(0, +)

            newTrail.forEach {
                baseScore = baseScore * wordMultiplier($0.2.multiplier)
            }

            // TODO: Doesn't account for when one version of the word scores more points
            if !OUTPUT.contains(where: { $0.hasSuffix(word2) }) {
                OUTPUT.insert("\(baseScore) \(word2)")
            }
        }

        if word2.count < 8 {
            p(word: word2, loc: possibleMove, trail: newTrail)
        }
    }
}

for row in matrix {
    for loc in row {
        var tl = matrix[loc.y][loc.x]
        let word = tl.2.letter
        tl.x = loc.x
        tl.y = loc.y
        p(word: word, loc: loc, trail: [tl])
    }
}

Array(OUTPUT)
    .sorted(by: { $0.localizedStandardCompare($1) == .orderedAscending })
    .forEach { word in
        print(word)
}



