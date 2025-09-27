// App/ContentView.swift

import SwiftUI

struct ContentView: View {
    // 1. Create a single CameraManager here as a @StateObject.
    // This instance will be the single source of truth for the camera.
    @StateObject private var cameraManager = CameraManager()
    
    var body: some View {
        TabView {
            // 2. Pass the same cameraManager instance into both views.
            MessageComposerView(cameraManager: cameraManager)
                .tabItem {
                    Label("Hide", systemImage: "eye.slash.fill")
                }
            
            MessageRevealView(cameraManager: cameraManager)
                .tabItem {
                    Label("Reveal", systemImage: "eye.fill")
                }
        }
        .accentColor(Color("AccentPurple"))
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
