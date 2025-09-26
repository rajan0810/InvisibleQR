import SwiftUI

struct MessageRevealView: View {
    @State private var capturedImage: UIImage?
    @State private var isAnalyzing = false
    @State private var isScanning = false
    @State private var foundMessage: String = ""
    @State private var showingMessage = false
    @State private var currentFingerprint = ""
    @State private var confidenceScore: Double = 0.0
    
    @StateObject private var textureAnalyzer = TextureAnalyzer()
    @EnvironmentObject var coreDataManager: CoreDataManager
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Reveal Hidden Secrets")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.purple)
            
            // Camera View
            CameraView(capturedImage: $capturedImage, isAnalyzing: $isAnalyzing)
                .frame(height: 300)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isScanning ? Color.blue : Color.gray, lineWidth: 3)
                )
                .overlay(
                    // Scanning animation
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.clear, Color.blue.opacity(0.3), Color.clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 2)
                        .offset(x: isScanning ? 150 : -150)
                        .animation(
                            Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                            value: isScanning
                        )
                )
            
            // Status Indicator
            HStack {
                Circle()
                    .fill(isScanning ? Color.blue : Color.gray)
                    .frame(width: 12, height: 12)
                
                Text(isScanning ? "Scanning for hidden messages..." : "Point camera at textured surface")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Scan Button
            Button(action: toggleScanning) {
                HStack {
                    Image(systemName: isScanning ? "stop.circle.fill" : "eye.fill")
                    Text(isScanning ? "Stop Scanning" : "Start Scanning")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isScanning ? Color.red : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(15)
            }
            .padding(.horizontal)
            
            // Results
            if !foundMessage.isEmpty {
                VStack(spacing: 15) {
                    Text("🎉 Secret Message Found!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text(foundMessage)
                        .font(.body)
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(10)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .transition(.scale.combined(with: .opacity))
            }
            
            Spacer()
        }
        .padding()
        .onChange(of: capturedImage) { _, newImage in
            if let image = newImage, isScanning {
                scanForMessage(image)
            }
        }
    }
    
    private func toggleScanning() {
        isScanning.toggle()
        
        if !isScanning {
            foundMessage = ""
        }
    }
    
    private func scanForMessage(_ image: UIImage) {
        DispatchQueue.global(qos: .userInitiated).async {
            let fingerprint = textureAnalyzer.analyzeTexture(from: image)
            
            if let hiddenMessage = coreDataManager.findMessage(by: fingerprint) {
                let decryptedMessage = CryptoService.decrypt(hiddenMessage.encryptedContent ?? Data())
                
                DispatchQueue.main.async {
                    withAnimation(.spring()) {
                        self.foundMessage = decryptedMessage
                        self.isScanning = false
                    }
                    
                    // Mark message as revealed
                    hiddenMessage.isRevealed = true
                    try? hiddenMessage.managedObjectContext?.save()
                }
            }
        }
    }
}
