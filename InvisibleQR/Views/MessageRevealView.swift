// Views/MessageRevealView.swift

import SwiftUI

struct MessageRevealView: View {
    // This toggle lets us switch between the two UI states in the preview.
    @State private var isMessageFound: Bool = false
    
    var body: some View {
        ZStack {
            // Dark background placeholder for the camera feed.
            Color.black.ignoresSafeArea()
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 300))
                .foregroundColor(.gray.opacity(0.1))
            
            VStack {
                Text("Reveal a Message")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundColor(Color("AccentPurple"))
                    .padding(.top)
                
                Spacer()
                
                // This logic switches between the two views.
                if isMessageFound {
                    // The view to display when a message is found.
                    MessageDisplayView(
                        message: "Meet me at the usual spot.",
                        locationHint: "The secret coffee shop table.",
                        similarity: 0.92
                    )
                } else {
                    // The view for when the user is scanning.
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
            
            // This button is ONLY for the preview to toggle the state.
            // We will remove this in the final functional version.
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

// This is a static component for displaying the found message.
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
