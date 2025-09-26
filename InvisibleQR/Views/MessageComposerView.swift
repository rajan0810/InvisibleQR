import SwiftUI

struct MessageComposerView: View {
    @State private var capturedImage: UIImage?
    @State private var isAnalyzing = false
    @State private var messageText = ""
    @State private var locationHint = ""
    @State private var currentFingerprint = ""
    @State private var confidenceScore: Double = 0.0
    @State private var showingSuccess = false
    
    @StateObject private var textureAnalyzer = TextureAnalyzer()
    @EnvironmentObject var coreDataManager: CoreDataManager
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Hide Your Secret")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.purple)
            
            // Camera View
            CameraView(capturedImage: $capturedImage, isAnalyzing: $isAnalyzing)
                .frame(height: 300)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(confidenceScore > 0.5 ? Color.green : Color.gray, lineWidth: 3)
                )
            
            // Confidence Indicator
            HStack {
                Text("Texture Quality:")
                    .fontWeight(.medium)
                
                ProgressView(value: confidenceScore)
                    .progressViewStyle(LinearProgressViewStyle(tint: confidenceScore > 0.5 ? .green : .orange))
                
                Text("\(Int(confidenceScore * 100))%")
                    .fontWeight(.bold)
                    .foregroundColor(confidenceScore > 0.5 ? .green : .orange)
            }
            .padding(.horizontal)
            
            // Message Input
            VStack(alignment: .leading, spacing: 10) {
                Text("Secret Message:")
                    .font(.headline)
                
                TextField("Type your secret message...", text: $messageText, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3...6)
                
                TextField("Location hint (optional)", text: $locationHint)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.caption)
            }
            .padding(.horizontal)
            
            // Hide Message Button
            Button(action: hideMessage) {
                HStack {
                    Image(systemName: "eye.slash.fill")
                    Text("Hide Message in Texture")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(canHideMessage ? Color.purple : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(15)
            }
            .disabled(!canHideMessage)
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .onChange(of: capturedImage) { _, newImage in
            if let image = newImage {
                analyzeTexture(image)
            }
        }
        .alert("Message Hidden Successfully!", isPresented: $showingSuccess) {
            Button("OK") {
                resetForm()
            }
        } message: {
            Text("Your secret message has been hidden in this texture. Share the location hint with someone special!")
        }
    }
    
    private var canHideMessage: Bool {
        !messageText.isEmpty && confidenceScore > 0.3 && !currentFingerprint.isEmpty
    }
    
    private func analyzeTexture(_ image: UIImage) {
        isAnalyzing = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let fingerprint = textureAnalyzer.analyzeTexture(from: image)
            
            DispatchQueue.main.async {
                self.currentFingerprint = fingerprint
                self.confidenceScore = textureAnalyzer.confidenceScore
                self.isAnalyzing = false
            }
        }
    }
    
    private func hideMessage() {
        guard canHideMessage else { return }
        
        coreDataManager.hideMessage(
            messageText,
            fingerprint: currentFingerprint,
            locationHint: locationHint.isEmpty ? nil : locationHint
        )
        
        showingSuccess = true
    }
    
    private func resetForm() {
        messageText = ""
        locationHint = ""
        currentFingerprint = ""
        confidenceScore = 0.0
        capturedImage = nil
    }
}
