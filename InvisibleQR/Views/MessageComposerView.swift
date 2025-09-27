// Views/MessageComposerView.swift

import SwiftUI
import Combine 

struct MessageComposerView: View {
    @State private var messageText: String = ""
    @State private var locationHint: String = ""
    
    // Create an instance of our simple camera service.
    @ObservedObject var cameraManager: CameraManager
    
    var body: some View {
        ZStack {
            // Display the live camera view.
            CameraView(cameraManager: cameraManager)
                .ignoresSafeArea()
            
            VStack {
                Text("Hide a Message")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundColor(Color("AccentPurple"))
                    .padding(.top)
                
                Spacer()
                
                VStack(spacing: 20) {
                    TextField("Enter your secret message...", text: $messageText)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(15)
                    
                    TextField("Location Hint (e.g., 'Behind the coffee machine')", text: $locationHint)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(15)
                    
                    VStack {
                        Text("92%")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color("AccentPurple"))
                        Text("Texture Clarity")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 10)
                    
                    Button {} label: {
                        Label("Hide Message", systemImage: "eye.slash.fill")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color("AccentPurple"))
                            .foregroundColor(.white)
                            .cornerRadius(20)
                    }
                }
                .padding()
                .background(.regularMaterial)
                .cornerRadius(25)
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            cameraManager.start()
        }
        .onDisappear {
            cameraManager.stop()
        }
    }
}

#Preview {
    // We pass a new, temporary CameraManager just for the preview to work.
    MessageComposerView(cameraManager: CameraManager())
}
