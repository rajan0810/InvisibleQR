// Views/MessageComposerView.swift

import SwiftUI

struct MessageComposerView: View {
    
    @StateObject private var viewModel: MessageComposerViewModel
    
    init(cameraManager: CameraManager) {
        // This properly initializes the ViewModel with the shared cameraManager
        _viewModel = StateObject(wrappedValue: MessageComposerViewModel(cameraManager: cameraManager))
    }
    
    var body: some View {
        ZStack {
            CameraView(cameraManager: viewModel.cameraManager)
                .ignoresSafeArea()
            
            VStack {
                Text("Hide a Message")
                    .font(.largeTitle).fontWeight(.heavy)
                    .foregroundColor(Color("AccentPurple"))
                    .padding(.top)
                
                Spacer()
                
                VStack(spacing: 15) {
                    TextField("Enter your secret message...", text: $viewModel.messageText)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(15)
                    
                    // This is now DYNAMIC and shows the live score!
//                    SimilarityIndicator(value: viewModel.textureClarity)
                    
//                    Text(viewModel.statusMessage)
//                        .font(.caption).foregroundStyle(.secondary)
//                        .multilineTextAlignment(.center)
//                        .animation(nil, value: viewModel.statusMessage)
//                        .frame(height: 30)

                    Button {
                        Task { await viewModel.hideMessage() }
                    } label: {
                        if viewModel.isHiding {
                            ProgressView().progressViewStyle(.circular).tint(.white)
                        } else {
                            Label("Hide Message", systemImage: "eye.slash.fill")
                        }
                    }
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color("AccentPurple"))
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .disabled(viewModel.messageText.isEmpty || viewModel.textureClarity < 0.7 || viewModel.isHiding)
                    .opacity(viewModel.messageText.isEmpty || viewModel.textureClarity < 0.7 ? 0.6 : 1.0)
                }
                .padding()
                .background(.regularMaterial)
                .cornerRadius(25)
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .animation(.easeInOut, value: viewModel.textureClarity)
        }
        .alert("Notice", isPresented: $viewModel.showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.alertMessage)
        }
    }
}
// Add this entire struct to the bottom of MessageComposerView.swift

struct SimilarityIndicator: View {
    var value: Double

    var body: some View {
        VStack {
            ZStack {
                Circle().stroke(Color.gray.opacity(0.3), lineWidth: 10)
                Circle().trim(from: 0.0, to: CGFloat(value))
                    .stroke(Color("AccentPurple"), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text(String(format: "%.0f%%", value * 100)).font(.title2).fontWeight(.bold)
            }
            .frame(width: 80, height: 80)
            Text("Texture Clarity").font(.caption).foregroundStyle(.secondary)
        }
    }
}
