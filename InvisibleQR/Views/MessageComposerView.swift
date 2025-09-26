// Views/MessageComposerView.swift

import SwiftUI

struct MessageComposerView: View {
    // These @State variables are placeholders to make the UI interactive in the preview.
    @State private var messageText: String = ""
    @State private var locationHint: String = ""
    
    var body: some View {
        ZStack {
            // In the final app, the camera feed will be here.
            // For now, we use a dark background to simulate the look.
            Color.black.ignoresSafeArea()
            
            // This is a placeholder for the live camera feed to give a textured feel.
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 300))
                .foregroundColor(.gray.opacity(0.1))
            
            VStack {
                // The main title of the screen.
                Text("Hide a Message")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundColor(Color("AccentPurple"))
                    .padding(.top)
                
                Spacer()
                
                // This container holds all the input controls.
                VStack(spacing: 20) {
                    // Text field for the secret message.
                    TextField("Enter your secret message...", text: $messageText)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(15)
                    
                    // Text field for the location hint.
                    TextField("Location Hint (e.g., 'Behind the coffee machine')", text: $locationHint)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(15)
                    
                    // This is where the dynamic SimilarityIndicator will go.
                    // For now, it's a static placeholder.
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
                    
                    // The main action button.
                    Button {
                        // This button does nothing for now.
                    } label: {
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
    }
}

#Preview {
    MessageComposerView()
}
