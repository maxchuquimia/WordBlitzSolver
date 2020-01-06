//
//  moves.swift
//  WordBlitzSolver
//
//  Created by Max Chuquimia on 6/1/20.
//  Copyright © 2020 Max Chuquimia. All rights reserved.
//

import Foundation

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
