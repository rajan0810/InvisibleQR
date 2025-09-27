// Views/MessageRevealView.swift

import SwiftUI

struct MessageRevealView: View {
    
    @StateObject private var viewModel: MessageRevealViewModel
    
    init(cameraManager: CameraManager) {
        _viewModel = StateObject(wrappedValue: MessageRevealViewModel(cameraManager: cameraManager))
    }

    var body: some View {
        ZStack {
            CameraView(cameraManager: viewModel.cameraManager)
                .ignoresSafeArea()
            
            VStack {
                Text("Reveal a Message")
                    .font(.largeTitle).fontWeight(.heavy)
                    .foregroundColor(Color("AccentPurple"))
                    .padding(.top)
                
                Spacer()
                
                // This UI now dynamically updates based on the ViewModel's state
                if let message = viewModel.foundMessage {
                    MessageDisplayView(
                        message: message,
                        similarity: viewModel.similarity
                    )
                    .onTapGesture {
                        viewModel.reset() // Tap the card to scan for another message
                    }
                } else {
                    VStack(spacing: 20) {
                        ProgressView().progressViewStyle(.circular)
                        Text(viewModel.statusMessage)
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                    }
                    .padding(.bottom, 60)
                }
            }
            .animation(.easeInOut, value: viewModel.foundMessage)
        }
    }
}
// Add this entire struct to the bottom of MessageRevealView.swift

struct MessageDisplayView: View {
    var message: String
    var similarity: Double

    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "hand.point.up.braille.fill").font(.largeTitle).foregroundColor(Color("AccentPurple"))
            Text("Hidden Message Revealed!").font(.headline)
            Text(message).font(.title2).fontWeight(.semibold)
            Divider().background(Color("AccentPurple").opacity(0.5))
            Text(String(format: "Match Confidence: %.1f%%", similarity * 100)).font(.subheadline)
        }
        .padding(25)
        .background(.ultraThinMaterial)
        .cornerRadius(25)
        .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color("AccentPurple"), lineWidth: 1))
        .padding(.horizontal)
    }
}
