import SwiftUI

@main
struct NeonStudioApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                // Standard YouTube/Video aspect ratio for clean recording
                .frame(minWidth: 1280, minHeight: 720)
        }
    }
}
