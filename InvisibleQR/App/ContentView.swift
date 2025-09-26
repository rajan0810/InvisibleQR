import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var coreDataManager = CoreDataManager.shared
    
    var body: some View {
        TabView {
            // Hide Message Tab
            NavigationView {
                MessageComposerView()
                    .environmentObject(coreDataManager)
            }
            .tabItem {
                Image(systemName: "eye.slash.fill")
                Text("Hide")
            }
            
            // Reveal Message Tab
            NavigationView {
                MessageRevealView()
                    .environmentObject(coreDataManager)
            }
            .tabItem {
                Image(systemName: "eye.fill")
                Text("Reveal")
            }
        }
        .accentColor(.purple)
    }
}
