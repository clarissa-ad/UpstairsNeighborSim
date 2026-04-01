import SwiftUI

struct ContentView: View {
    @StateObject private var engine = TrackingEngine()
    
    var body: some View {
        ZStack {
            // Pure black background for clean video editing
            Color.black.ignoresSafeArea()
            
            if let cgImage = engine.outlineImage {
                // Display the outline image
                Image(decorative: cgImage, scale: 1.0, orientation: .up)
                    .resizable()
                    .scaledToFill()
                    // 1. MIRROR IT! So when you move right, the screen moves right
                    .scaleEffect(x: -1, y: 1)
                    // 2. COLOR IT! Tint the white line to any neon color you want
                    .colorMultiply(.white) // ⬅️ Change to .cyan or .green if you want!
                    // 3. GLOW IT!
                    .shadow(color: .white, radius: 10)
                    .shadow(color: .white, radius: 5)
            } else {
                Text("Warming up camera...")
                    .foregroundColor(.gray)
            }
        }
        .onAppear {
            engine.start()
        }
    }
}
