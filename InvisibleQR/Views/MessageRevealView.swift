// Views/MessageRevealView.swift

import SwiftUI
import Combine 

struct MessageRevealView: View {
    @State private var isMessageFound: Bool = false
    
    // Create an instance of our simple camera service.
    @StateObject private var cameraManager = CameraManager()
    
    var body: some View {
        ZStack {
            // Display the live camera view.
            CameraView(cameraManager: cameraManager)
                .ignoresSafeArea()
            
            VStack {
                Text("Reveal a Message")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundColor(Color("AccentPurple"))
                    .padding(.top)
                
                Spacer()
                
                if isMessageFound {
                    MessageDisplayView(
                        message: "Meet me at the usual spot.",
                        locationHint: "The secret coffee shop table.",
                        similarity: 0.92
                    )
                } else {
                    VStack {
                        Text("78%")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color("AccentPurple"))
                        Text("Scanning for message...")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                    }
                    .padding(.bottom, 60)
                }
            }
            
            // Preview-only toggle button
            VStack {
                Spacer()
                Button("Toggle Preview State") {
                    withAnimation {
                        isMessageFound.toggle()
                    }
                }
                .padding(.bottom)
            }
        }
    }
}

// No changes needed for this part
struct MessageDisplayView: View {
    var message: String
    var locationHint: String
    var similarity: Double

    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "hand.point.up.braille.fill")
                .font(.largeTitle)
                .foregroundColor(Color("AccentPurple"))
            
            Text("Hidden Message Revealed!")
                .font(.headline)
            
            Text(message)
                .font(.title2)
                .fontWeight(.semibold)
            
            Divider().background(Color("AccentPurple").opacity(0.5))
            
            Text("Hint: \(locationHint)")
                .font(.subheadline)
        }
        .padding(25)
        .background(.ultraThinMaterial)
        .cornerRadius(25)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color("AccentPurple"), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

#Preview {
    MessageRevealView()
}
