import SwiftUI

// Used to track which side of the screen they need to wave to next
enum PartySide {
    case left, right
}

struct PartyScene: View {
    @ObservedObject var engine: TrackingEngine
    @Binding var score: Int
    var onComplete: (Bool) -> Void // Kept so the GamePageView contract stays intact
    
    // 🔧 Infinite Game State
    @State private var hits: Int = 0
    @State private var currentSide: PartySide = .left
    @State private var bgColor: Color = .black
    
    // 🪩 Disco colors for when they hit a zone
    let partyColors: [Color] = [.purple, .blue, .green, .red, .orange, .cyan]
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 1. The Disco Background (Flashes on hit)
                bgColor.ignoresSafeArea()
                
                // 2. HUD & Instructions
                VStack {
                    Text("ANGKAT TANGAN!")
                        .font(.system(size: 50, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .purple, radius: 10)
                        
                    // 🔧 UPDATE: Uncapped wave counter!
                    Text("WAVES: \(hits)!")
                        .font(.title.bold())
                        .foregroundColor(.yellow)
                        
                    Spacer()
                }
                .padding(40)
                .zIndex(2)
                
                // 3. The Target Zones
                HStack(spacing: 0) {
                    // LEFT HIT ZONE
                    Rectangle()
                        .fill(currentSide == .left ? Color.white.opacity(0.2) : Color.clear)
                        .frame(width: geo.size.width / 3)
                        .overlay(
                            Text(currentSide == .left ? "👋 SINI!" : "")
                                .font(.title.bold())
                                .foregroundColor(.white)
                        )
                    
                    Spacer()
                    
                    // RIGHT HIT ZONE
                    Rectangle()
                        .fill(currentSide == .right ? Color.white.opacity(0.2) : Color.clear)
                        .frame(width: geo.size.width / 3)
                        .overlay(
                            Text(currentSide == .right ? "SINI! 👋" : "")
                                .font(.title.bold())
                                .foregroundColor(.white)
                        )
                }
            }
            // 4. The Logic Loop
            .onChange(of: engine.hands) {
                checkWaveLogic()
            }
        }
    }
    
    private func checkWaveLogic() {
        // Look at all detected hands
        for hand in engine.hands {
            // Because the front camera is a mirror, we invert the X coordinate
            let xPos = 1.0 - hand.indexTip.x
            
            // Check if hand entered the active target zone
            if currentSide == .left && xPos < 0.35 {
                triggerHit(nextSide: .right)
                break // Stop checking other hands this frame to prevent double-hits
            } else if currentSide == .right && xPos > 0.65 {
                triggerHit(nextSide: .left)
                break
            }
        }
    }
    
    private func triggerHit(nextSide: PartySide) {
        // 🔊 Play the whoosh instantly
        AudioManager.shared.playSFX("whoosh")
        
        // 1. Instantly swap the target side so they have to wave back
        currentSide = nextSide
        
        // 2. Add points!
        hits += 1
        score += 20
        
        // 3. Disco Lighting! Flash a random neon color, then fade back to black
        let newColor = partyColors.randomElement() ?? .purple
        withAnimation(.easeIn(duration: 0.05)) {
            bgColor = newColor
        }
        withAnimation(.easeOut(duration: 0.3).delay(0.05)) {
            bgColor = .black
        }
    }
}

// 🔧 PREVIEW SUPPORT
struct PartyScene_Previews: PreviewProvider {
    static var previews: some View {
        PartyScene(
            engine: TrackingEngine(),
            score: .constant(100),
            onComplete: { _ in }
        )
        .background(Color.black)
    }
}
