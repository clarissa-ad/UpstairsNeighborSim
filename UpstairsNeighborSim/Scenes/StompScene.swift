import SwiftUI

struct StompScene: View {
    @ObservedObject var engine: TrackingEngine
    @Binding var score: Int
    var onWin: () -> Void
    
    @State private var hasStomped = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 1. Custom Text Placement (Top Left for this game)
                VStack {
                    HStack {
                        Text("INJAK!")
                            .font(.system(size: 80, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .orange, radius: 10)
                            .rotationEffect(.degrees(-10)) // Make it look chaotic
                        Spacer()
                    }
                    Spacer()
                }
                .padding(40)
                
                // 2. Visual Target (The Floor)
                VStack {
                    Spacer()
                    Rectangle()
                        .fill(hasStomped ? Color.white : Color.red.opacity(0.5))
                        .frame(height: 100)
                        .overlay(Text(hasStomped ? "BOOM!" : "STOMP HERE").font(.title.bold()))
                }
            }
            // 3. The Logic (Listening to the Engine in the background)
            .onChange(of: engine.hands) { _ in
                checkStompLogic(in: geo.size)
            }
        }
    }
    
    private func checkStompLogic(in size: CGSize) {
        guard !hasStomped else { return } // Don't trigger twice
        
        for hand in engine.hands {
            // The AI tracks Y from 0.0 (top) to 1.0 (bottom)
            // If the wrist goes below 80% of the screen height, it's a STOMP!
            if hand.wrist.y > 0.8 {
                triggerWin()
                break
            }
        }
    }
    
    private func triggerWin() {
        hasStomped = true
        score += 100 // Add Noise Units!
        
        // Add a tiny delay so the player sees the "BOOM!" before the game switches
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onWin()
        }
    }
}
