// App/ContentView.swift

import SwiftUI

struct ContentView: View {
    var body: some View {
        // This TabView is the main navigation of the app.
        TabView {
            // First Tab: The screen for hiding a message.
            MessageComposerView()
                .tabItem {
                    Label("Hide", systemImage: "eye.slash.fill")
                }
            
            // Second Tab: The screen for revealing a message.
            MessageRevealView()
                .tabItem {
                    Label("Reveal", systemImage: "eye.fill")
                }
        }
        // This applies our custom purple color to the tab icons.
        .accentColor(Color("AccentPurple"))
        // This forces the app into a dark theme, as per our design.
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
