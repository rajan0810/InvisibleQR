// ViewModels/MessageComposerViewModel.swift

import Foundation
import Combine
import SwiftUI // <-- Make sure SwiftUI is imported

@MainActor
class MessageComposerViewModel: ObservableObject {
    
    @Published var messageText: String = ""
    @Published var textureClarity: Double = 0.0
    @Published var statusMessage: String = "Point at a texture..."
    @Published var isHiding: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""

    @ObservedObject var cameraManager: CameraManager
    
    private let analyzer = CoreMLTextureAnalyzer()
    private let cryptoService = CryptoService()
    private var lastAnalyzedVector: [Float]?
    private var cancellables = Set<AnyCancellable>()

    init(cameraManager: CameraManager) {
        self.cameraManager = cameraManager
        
        // Listen for new CGImage frames from the camera.
        cameraManager.$capturedFrame
            .compactMap { $0 }
            .sink { [weak self] cgImage in
                self?.analyzeFrame(cgImage)
            }
            .store(in: &cancellables)
    }

    // This function now accepts a CGImage.
    private func analyzeFrame(_ cgImage: CGImage) {
        Task {
            do {
                let (features, confidence) = try await analyzer.extractFeatures(from: cgImage)
                
                self.textureClarity = confidence
                
                if confidence > 0.7 {
                    self.lastAnalyzedVector = features
                }
                
                if confidence < 0.3 {
                    self.statusMessage = "Find a more detailed texture."
                } else {
                    self.statusMessage = "Excellent texture! Ready to hide."
                }
            } catch {
                self.statusMessage = "Could not analyze texture."
            }
        }
    }
    
    func hideMessage() async {
        // ... this function's logic remains the same ...
        guard !messageText.isEmpty else {
            alertMessage = "Please enter a message to hide."
            showAlert = true
            return
        }
        
        guard let featureVector = lastAnalyzedVector else {
            alertMessage = "Texture quality is too low. Find a clearer surface."
            showAlert = true
            return
        }
        
        isHiding = true
        self.statusMessage = "Encrypting message..."
        
        do {
            guard let encrypted = try cryptoService.encrypt(messageText) else {
                throw NSError(domain: "CryptoError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Encryption failed."])
            }
            
            self.statusMessage = "Hiding message in texture..."
            try await NetworkManager.shared.hideMessage(featureVector: featureVector, encryptedMessage: encrypted)
            
            self.statusMessage = "Success! Message hidden."
            self.messageText = ""
            
        } catch {
            alertMessage = "Error: \(error.localizedDescription)"
            showAlert = true
            self.statusMessage = "Failed to hide message."
        }
        
        isHiding = false
    }
}
