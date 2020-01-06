//
//  ocr.swift
//  WordBlitzSolver
//
//  Created by Max Chuquimia on 5/1/20.
//  Copyright © 2020 Max Chuquimia. All rights reserved.
//

import Cocoa
import Vision

typealias OCRResult = (score: Int, multiplier: String?, letter: String)

func ocr(on image: NSImage, minimumTextHeight: Float? = nil) -> OCRResult {

    var score: Int = 0
    var multiplier: String?
    var letter: String = ""

    let tess = SLTesseract()
    tess.language = "eng"
    tess.charWhitelist = "ABCDEFGHIJKLMNOPQRSTUVWXYZ123456789"
    tess.charBlacklist = "0"

    letter = tess.recognize(image)
    print(letter)

    return (score, multiplier, letter.uppercased())
}
