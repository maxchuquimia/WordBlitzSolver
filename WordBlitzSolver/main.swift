//
//  main.swift
//  WordBlitzSolver
//
//  Created by Max Chuquimia on 5/1/20.
//  Copyright © 2020 Max Chuquimia. All rights reserved.
//

import Foundation
import ShellSwift

typealias Loc = (x: Int, y: Int)
typealias Matrix = [[String]]

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



//let INPUT_STRING = "".uppercased()
//let SPECIAL_LOC: Loc = (1, 2)
////let SPECIAL_LOC: Loc = (<#x#>, <#y#>)

let INPUT_STRING = CommandLine.arguments[1]
let SPECIAL_LOC: Loc = (Int(CommandLine.arguments[2])!, Int(CommandLine.arguments[3])!)

let MATRIX_BOUNDS = 3 // Max index of matric cols and rows

let matrix: Matrix = INPUT_STRING
    .uppercased()
    .separate(every: 4, with: "\n")
    .components(separatedBy: "\n")
    .map { $0.map(String.init) }

print(matrix)
print(SPECIAL_LOC)

//print(matrix)
//print(file.contains("XIS"))


func moves(from loc: Loc, in matrix: Matrix, excluding locsToExclude: [Loc] = []) -> [Loc] {
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
        !locsToExclude.contains(where: { $0 == newLoc })
    }
}

//print(moves(from: (3, 3), in: matrix))

var OUTPUT: Set<String> = []
var SPECIAL: Set<String> = []

func p(word: String, loc: Loc, trail: [Loc]) {
    let possibleMoves = moves(from: loc, in: matrix, excluding: trail)

    for possibleMove in possibleMoves {
        let newTrail = trail + [possibleMove]
        let word2 = word + matrix[possibleMove.y][possibleMove.x]

        if allWords.contains(word2) {
            //print(word2)
            OUTPUT.insert(word2)

            if trail.contains(where: { $0 == SPECIAL_LOC }) {
                SPECIAL.insert(word2)
            }
        }

        if word2.count < 8 {
            p(word: word2, loc: possibleMove, trail: newTrail)
        }
    }
}

for (rowIndex, row) in matrix.enumerated() {
    for (columnIndex, _) in row.enumerated() {
        let loc: Loc = (rowIndex, columnIndex)

        let word = matrix[loc.y][loc.x]
       // print("=>", word)

        p(word: word, loc: loc, trail: [loc])

//        var possibleMoves = moves(from: loc, in: matrix)
//
//        for possibleMove in possibleMoves {
//            var word2 = word + matrix[possibleMove.y][possibleMove.x]
//            print(word2)
//
////            let furtherMoves = moves(from: possibleMove, in: matrix, excluding: possibleMoves)
//        }

//        exit(0)
    }
}

Array(OUTPUT)
    .sorted(by: { $0.count < $1.count })
    .forEach { word in
        print(word, terminator:  SPECIAL.contains(word) ? "  !!!\n" : "\n")
}



