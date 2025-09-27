// ViewModels/MessageRevealViewModel.swift

import Foundation
import Combine
import SwiftUI
import CoreImage

@MainActor
class MessageRevealViewModel: ObservableObject {
    @Published var statusMessage: String = "Scanning for hidden messages..."
    @Published var foundMessage: String?
    @Published var similarity: Double = 0.0
    
    @ObservedObject var cameraManager: CameraManager
    
    private let analyzer = CoreMLTextureAnalyzer()
    private let cryptoService = CryptoService()
    private var isSearching = false
    private var cancellables = Set<AnyCancellable>()

    init(cameraManager: CameraManager) {
        self.cameraManager = cameraManager
        
        // Listen for frames and call findMessage after a short delay (debounce)
        cameraManager.$capturedFrame
            .compactMap { $0 }
            .debounce(for: .seconds(0.75), scheduler: DispatchQueue.main)
            .sink { [weak self] cgImage in
                self?.findMessage(in: cgImage)
            }
            .store(in: &cancellables)
    }

    private func findMessage(in cgImage: CGImage) {
        guard !isSearching, foundMessage == nil else { return }
        
        isSearching = true
        self.statusMessage = "Analyzing texture..."
        
        Task {
            do {
                // --- START OF LOGS ---
                print("---------------------------------")
                print("SCANNING [\(Date().formatted(date: .omitted, time: .standard)))]")

                print("1. Analyzing current frame...")
                let (features, confidence) = try await analyzer.extractFeatures(from: cgImage)
                print("   - Clarity: \(String(format: "%.2f", confidence))")
                print("   - Vector (first 5): [\(features.prefix(5).map { String(format: "%.3f", $0) }.joined(separator: ", "))]...")

                self.statusMessage = "Searching..."
                print("2. Sending vector to Supabase to search for a match...")
                let response = try await NetworkManager.shared.findSimilarMessage(featureVector: features)
                
                if response.found, let encrypted = response.encryptedMessage {
                    print("3. ✅ Match FOUND! Similarity: \(String(format: "%.2f", response.similarity ?? 0))")
                    self.statusMessage = "Match Found! Decrypting..."
                    if let decrypted = try cryptoService.decrypt(encrypted) {
                        print("4. ✅ Decryption successful: '\(decrypted)'")
                        self.foundMessage = decrypted
                        self.similarity = response.similarity ?? 0
                    } else {
                        print("4. ❌ Decryption FAILED.")
                        self.statusMessage = "Decryption Failed."
                    }
                } else {
                    print("3. ❌ No match found in database.")
                    self.statusMessage = "No message found here. Keep scanning."
                }
                
            } catch {
                print("‼️ ERROR during reveal process: \(error.localizedDescription)")
                self.statusMessage = "An error occurred."
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
