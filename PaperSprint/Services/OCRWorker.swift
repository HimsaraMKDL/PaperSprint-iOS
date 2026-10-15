import Foundation
import Vision
import ImageIO
import UniformTypeIdentifiers

struct OCRResponse: Sendable {
    let text: String
    let previewData: Data
}
enum OCRError: LocalizedError {
    case unreadableImage
    case imageTooLarge
    var errorDescription: String? {
        switch self {
        case .unreadableImage: return "This image could not be opened. Try a clear PNG or JPEG image."
        case .imageTooLarge: return "Choose an image smaller than 20 MB."
        }
    }
}

/// Actor isolation keeps decoding and Vision work off the UI actor. Only Data/String cross the boundary.
actor OCRWorker {
    func recognize(data: Data) throws -> OCRResponse {
        guard data.count <= 20 * 1024 * 1024 else { throw OCRError.imageTooLarge }
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let image = CGImageSourceCreateThumbnailAtIndex(source, 0, [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceThumbnailMaxPixelSize: 2400
              ] as CFDictionary) else { throw OCRError.unreadableImage }
        // ThumbnailWithTransform applies EXIF orientation before OCR.
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en-US"]
        request.usesLanguageCorrection = true
        let handler = VNImageRequestHandler(cgImage: image, orientation: .up, options: [:])
        try handler.perform([request])
        let text = (request.results ?? []).compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
        let output = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(output as CFMutableData, UTType.jpeg.identifier as CFString, 1, nil)
        else { throw OCRError.unreadableImage }
        CGImageDestinationAddImage(destination, image, [kCGImageDestinationLossyCompressionQuality: 0.85] as CFDictionary)
        guard CGImageDestinationFinalize(destination) else { throw OCRError.unreadableImage }
        return OCRResponse(text: text, previewData: output as Data)
    }
}
