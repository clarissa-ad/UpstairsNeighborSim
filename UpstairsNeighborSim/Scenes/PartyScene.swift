import SwiftUI

// Used to track which side of the screen they need to wave to next
enum PartySide {
    case left, right
}

struct PartyScene: View {
    // 🔧 STANDARD CONTRACT (Order matters!)
    @ObservedObject var engine: TrackingEngine
    @Binding var score: Int
    var playerZone: PlayerZone = .solo
    var onComplete: (Bool) -> Void
    
    // 🔧 Infinite Game State
    @State private var hits: Int = 0
    @State private var currentSide: PartySide = .left
    // 🛑 FIX 1: Start completely transparent so the camera shows through!
    @State private var bgColor: Color = .clear
    
    // 🪩 Disco colors for when they hit a zone
    let partyColors: [Color] = [.purple, .blue, .green, .red, .orange, .cyan]
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 1. The Disco Background Filter (Flashes on hit)
                bgColor.ignoresSafeArea()
                
                // 2. HUD & Instructions
                VStack {
                    Text("ANGKAT TANGAN!")
                        .font(.system(size: 50, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .purple, radius: 10)
                        
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
            // 4. The Logic Loop (Passing in geo.size for the math!)
            .onChange(of: engine.hands) {
                checkWaveLogic(in: geo.size)
            }
        }
    }
    
    private func checkWaveLogic(in size: CGSize) {
        // 🛑 1. MULTIPLAYER FILTER: Ignore the other player's hands
        let validHands = engine.hands.filter {
            CoordinateMapper.belongsToZone(rawX: $0.indexTip.x, zone: playerZone)
        }
        
        for hand in validHands {
            // 🎯 2. UNIVERSAL LENS: Map the raw camera X to this specific UI view
            let localPoint = CoordinateMapper.localPoint(rawPoint: hand.indexTip, zone: playerZone, screenSize: size)
            
            // Convert pixels back to a percentage (0.0 to 1.0) for the local UI bounds
            let localX = localPoint.x / size.width
            
            // 3. HIT DETECTION: Check if they reached the active 33% zone
            if currentSide == .left && localX < 0.35 {
                triggerHit(nextSide: .right)
                break // Stop checking other hands this frame to prevent double-hits
            } else if currentSide == .right && localX > 0.65 {
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
        
        // 3. Disco Filter Logic!
        let newColor = partyColors.randomElement() ?? .purple
        withAnimation(.easeIn(duration: 0.05)) {
            // 🛑 FIX 2: Apply lowered transparency (opacity) to act as a camera filter
            bgColor = newColor.opacity(0.5)
        }
        withAnimation(.easeOut(duration: 0.3).delay(0.05)) {
            // 🛑 FIX 3: Fade back to completely clear instead of black!
            bgColor = .clear
        }
    }
}

// 🔧 PREVIEW SUPPORT
struct PartyScene_Previews: PreviewProvider {
    static var previews: some View {
        PartyScene(engine: TrackingEngine(), score: .constant(100), onComplete: { _ in })
            .background(Color.black)
    }
}
