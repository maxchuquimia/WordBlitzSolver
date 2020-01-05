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

func ocr(on image: CGImage, minimumTextHeight: Float? = nil) -> OCRResult {

    var score: Int = 0
    var multiplier: String?
    var letter: String = ""

    let pause = DispatchSemaphore(value: 0)
    let request = VNRecognizeTextRequest { request, error in
        guard let observations = request.results as? [VNRecognizedTextObservation] else {
            fatalError("Received invalid observations")
        }

        for observation in observations {
            guard let bestCandidate = observation.topCandidates(1).first else {
                print("No candidate")
                continue
            }

            print("Found this candidate: \(bestCandidate.string)")

            if bestCandidate.string.count == 2 {
                multiplier = bestCandidate.string
            } else if let s = Int(bestCandidate.string) {
                score = s
            } else {
                letter = bestCandidate.string
            }
        }
        pause.signal()
    }

    request.recognitionLevel = .accurate

    request.customWords = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "2L", "3L", "2W", "3W", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    request.recognitionLanguages = ["en"]
//    request.usesLanguageCorrection = false

    if let minimumTextHeight = minimumTextHeight {
        request.minimumTextHeight = minimumTextHeight
    }

    let handler = VNImageRequestHandler(cgImage: image, options: [:])
    try! handler.perform([request])

    pause.wait()

    if letter.isEmpty {
        print(image)
    }

    return (score, multiplier, letter.uppercased())
}
