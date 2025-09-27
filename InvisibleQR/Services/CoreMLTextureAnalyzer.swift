// Services/CoreMLTextureAnalyzer.swift

import Vision
import CoreImage

enum AnalyzerError: Error {
    case featureExtractionFailed
    case dataConversionFailed
}

class CoreMLTextureAnalyzer {
    
    private let requestHandler = VNSequenceRequestHandler()
    private let featurePrintRequest = VNGenerateImageFeaturePrintRequest()

    func extractFeatures(from cgImage: CGImage) async throws -> ([Float], Double) {
        
        try requestHandler.perform([featurePrintRequest], on: cgImage)
        
        guard let result = featurePrintRequest.results?.first else {
            throw AnalyzerError.featureExtractionFailed
        }
        
        // --- THIS IS THE FIX ---
        // 1. The correct property is `.data`, not `.elementalFeatureVector`.
        // This gives us the raw binary data of the vector.
        let featureVectorData = result.data
        
        // 2. We need to convert this raw data into an array of Float numbers.
        let floatArray = featureVectorData.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) -> [Float] in
            return Array(buffer.bindMemory(to: Float.self))
        }
        
        guard !floatArray.isEmpty else {
            throw AnalyzerError.dataConversionFailed
        }
        // --- END OF FIX ---
        
        let confidence = calculateConfidence(from: floatArray)

        return (floatArray, confidence)
    }

    private func calculateConfidence(from vector: [Float]) -> Double {
        let mean = vector.reduce(0, +) / Float(vector.count)
        let variance = vector.map { pow($0 - mean, 2) }.reduce(0, +) / Float(vector.count)
        return min(1.0, Double(variance * 1000))
    }
}
