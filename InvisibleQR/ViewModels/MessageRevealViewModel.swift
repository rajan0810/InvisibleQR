// ViewModels/MessageRevealViewModel.swift

import Foundation
import Combine
import SwiftUI   // <-- FIX #1: Added the missing import for SwiftUI
import CoreImage // We use CGImage which is part of CoreImage/CoreGraphics

@MainActor
class MessageRevealViewModel: ObservableObject {
    @Published var statusMessage: String = "Scanning for hidden messages..."
    @Published var foundMessage: String?
    @Published var similarity: Double = 0.0
    
    // This now works because SwiftUI is imported
    @ObservedObject var cameraManager: CameraManager
    
    private let analyzer = CoreMLTextureAnalyzer()
    private let cryptoService = CryptoService()
    private var isSearching = false
    private var cancellables = Set<AnyCancellable>()

    init(cameraManager: CameraManager) {
        self.cameraManager = cameraManager
        
        // Listen for CGImage frames and debounce to avoid spamming the backend
        cameraManager.$capturedFrame
            .compactMap { $0 }
            .debounce(for: .seconds(0.75), scheduler: DispatchQueue.main)
            .sink { [weak self] cgImage in // <-- FIX #2: Now receives a CGImage
                self?.findMessage(in: cgImage)
            }
            .store(in: &cancellables)
    }

    // This function now accepts a CGImage
    private func findMessage(in cgImage: CGImage) {
        guard !isSearching, foundMessage == nil else { return }
        
        isSearching = true
        self.statusMessage = "Analyzing texture..."
        
        Task {
            do {
                // The analyzer is now called with the CGImage
                let (features, _) = try await analyzer.extractFeatures(from: cgImage)
                
                self.statusMessage = "Searching..."
                let response = try await NetworkManager.shared.findSimilarMessage(featureVector: features)
                
                if response.found, let encrypted = response.encryptedMessage {
                    self.statusMessage = "Match Found! Decrypting..."
                    if let decrypted = try cryptoService.decrypt(encrypted) {
                        self.foundMessage = decrypted
                        self.similarity = response.similarity ?? 0
                    }
                } else {
                    self.statusMessage = "No message found here. Keep scanning."
                }
                
            } catch {
                self.statusMessage = "Error: \(error.localizedDescription)"
            }
            isSearching = false
        }
    }
    
    func reset() {
        foundMessage = nil
        similarity = 0.0
        statusMessage = "Scanning for hidden messages..."
    }
}
