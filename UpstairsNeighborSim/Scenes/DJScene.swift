import SwiftUI

struct DJScene: View {
    // 🔧 STANDARD CONTRACT (Perfect order to avoid Xcode errors!)
    @ObservedObject var engine: TrackingEngine
    @Binding var score: Int
    var playerZone: PlayerZone = .solo
    var onComplete: (Bool) -> Void
    
    // 🔧 Game State
    @State private var hypeLevel: CGFloat = 0.0
    @State private var previousPositions: [CGFloat] = []
    @State private var dropCount: Int = 0 // Tracks how many times they filled the bar
    @State private var isHandsPresent: Bool = false
    
    // 📐 The Math: Lowered to 4.0 so they can trigger multiple "Drops" in the 5-second time limit!
    let requiredHype: CGFloat = 4.0
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 1. Instructions & Hype Meter
                VStack {
                    Text("NGE-DJ!")
                        .font(.system(size: 60, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .purple, radius: 10)
                    
                    Text("BEAT DROPS: \(dropCount)!")
                        .font(.title.bold())
                        .foregroundColor(.yellow)
                    
                    // The Hype Progress Bar
                    GeometryReader { barGeo in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 30)
                            
                            Rectangle()
                                .fill(LinearGradient(colors: [.purple, .cyan], startPoint: .leading, endPoint: .trailing))
                                .frame(width: min(barGeo.size.width, barGeo.size.width * (hypeLevel / requiredHype)), height: 30)
                                .animation(.linear(duration: 0.1), value: hypeLevel)
                        }
                        .cornerRadius(15)
                    }
                    .frame(height: 30)
                    .padding(.horizontal, 40)
                    
                    // Warning if hands are missing
                    if !isHandsPresent {
                        Text("⚠️ PUT BOTH HANDS UP! ⚠️")
                            .font(.title.bold())
                            .foregroundColor(.red)
                            .padding(.top, 10)
                    }
                    
                    Spacer()
                }
                .padding(40)
                
                // 2. The Visual DJ Decks
                HStack(spacing: geo.size.width * 0.2) {
                    DJDeckView(hype: hypeLevel, isActive: isHandsPresent)
                    DJDeckView(hype: hypeLevel, isActive: isHandsPresent)
                }
                .position(x: geo.size.width / 2, y: geo.size.height * 0.6)
            }
            .onChange(of: engine.hands) {
                checkScratchLogic()
            }
        }
    }
    
    private func checkScratchLogic() {
        // 🛑 MULTIPLAYER FILTER: Calculate this fresh every single frame!
        let validHands = engine.hands.filter {
            CoordinateMapper.belongsToZone(rawX: $0.indexTip.x, zone: playerZone)
        }
        
        // Update UI state
        isHandsPresent = (validHands.count >= 2)
        
        // 🚨 STRICT RULE: Math pauses if 2 hands are not visible on THEIR side
        guard validHands.count >= 2 else {
            previousPositions = [] // Reset the math so it doesn't glitch
            return
        }
        
        // 1. Get the X coordinates of both index fingers
        let currentPositions = validHands.prefix(2).map { $0.indexTip.x }.sorted()
        
        if previousPositions.count == 2 {
            // 2. Calculate "Delta" (How far did they move?)
            let leftDelta = abs(currentPositions[0] - previousPositions[0])
            let rightDelta = abs(currentPositions[1] - previousPositions[1])
            
            // 3. Add movement to the Hype Meter!
            hypeLevel += (leftDelta + rightDelta)
            
            // 4. Score Attack Loop! (No more 'hasWon' limits)
            if hypeLevel >= requiredHype {
                triggerBeatDrop()
            }
        }
        
        // Save current positions for the next frame's math
        previousPositions = currentPositions
    }
    
    private func triggerBeatDrop() {
        // 🔊 Sound Effect
        AudioManager.shared.playSFX("stomp") // Or whatever airhorn/bass drop sound you have!
        
        // Add points and reset the bar so they can do it again!
        withAnimation(.spring()) {
            dropCount += 1
            score += 50
            hypeLevel = 0.0 // Instantly reset to 0
            previousPositions = []
        }
    }
}

// 🔧 Visual sub-view for the spinning records
struct DJDeckView: View {
    var hype: CGFloat
    var isActive: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black)
                .frame(width: 150, height: 150)
                .shadow(color: isActive ? .cyan : .clear, radius: 20)
            
            Circle()
                .stroke(Color.gray, lineWidth: 2)
                .frame(width: 100, height: 100)
            
            Circle()
                .fill(Color.red)
                .frame(width: 40, height: 40)
        }
        // The record physically spins faster the more you move your hands!
        .rotationEffect(.degrees(Double(hype * 180)))
        .opacity(isActive ? 1.0 : 0.5)
    }
}

// 🔧 PREVIEW SUPPORT
struct DJScene_Previews: PreviewProvider {
    static var previews: some View {
        DJScene(engine: TrackingEngine(), score: .constant(0), onComplete: { _ in })
            .background(Color.black)
    }
}
