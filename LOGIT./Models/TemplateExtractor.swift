//
//  TemplateExtractor.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 01.08.23.
//

import OSLog
import SwiftUI
import Vision

struct TemplateExtractor {
    
    func createTemplate(from image: UIImage) {
        let text = readText(from: image)
        OpenAI
    }
    
    private func readText(from image: UIImage) -> String? {
        guard let cgImage = image.cgImage else { return nil }
        // Create a new image-request handler.
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        // Create a new request to recognize text.
        var result: String?
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation],
                  error == nil else {return}
            let text = observations.compactMap({
                $0.topCandidates(1).first?.string
            }).joined(separator: ", ")
            result = text
        }
        do {
            try requestHandler.perform([request])
        } catch {
            Logger().error("TemplateExtractor: Unable to read text from image: \(error).")
        }
        return result
    }
    
}
