import SwiftUI

struct StompScene: View {
    @ObservedObject var engine: TrackingEngine
    @Binding var score: Int
    var playerZone: PlayerZone = .solo
    var onComplete: (Bool) -> Void
    
    // 🔧 Simplified Game State
    @State private var hitCount: Int = 0
    @State private var isReady: Bool = true
    @State private var flashColor: Color = .red.opacity(0.5)
    
    // 📐 The Math
    let stompLine: CGFloat = 0.75 // Hand goes below 75% -> STOMP
    let resetLine: CGFloat = 0.60 // Hand goes above 60% -> RESET
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 1. Instructions & Hit Counter
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("INJAK!")
                                .font(.system(size: 60, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(color: .orange, radius: 10)
                                .rotationEffect(.degrees(-10))
                            
                            // 🔧 UPDATE: Uncapped counter!
                            Text("STOMPS: \(hitCount)!")
                                .font(.title.bold())
                                .foregroundColor(.yellow)
                        }
                        Spacer()
                    }
                    Spacer()
                }
                .padding(40)
                
                // 2. The Hit Zone
                VStack {
                    Spacer()
                    Rectangle()
                        .fill(flashColor)
                        .frame(height: geo.size.height * (1.0 - stompLine))
                        .overlay(
                            Text(isReady ? "STOMP DOWN!" : "LIFT HAND UP!")
                                .font(.title.bold())
                                .foregroundColor(.white)
                        )
                }
            }
            // 3. The Logic Loop
            .onChange(of: engine.hands) {
                checkStompLogic()
            }
        }
    }
    
    private func checkStompLogic() {
        // 🛑 1. FILTER: Ignore the other player's hands!
        let validHands = engine.hands.filter { CoordinateMapper.belongsToZone(rawX: $0.indexTip.x, zone: playerZone) }
        
        var lowestFingerY: CGFloat = 0.0
        var highestFingerY: CGFloat = 1.0
        
        // 2. Loop through validHands, NOT engine.hands
        for hand in validHands {
            lowestFingerY = max(lowestFingerY, hand.indexTip.y)
            highestFingerY = min(highestFingerY, hand.indexTip.y)
        }
        
        // STEP 1: The Reset (Hand is lifted UP)
        if highestFingerY < resetLine && !isReady {
            isReady = true
            flashColor = .red.opacity(0.5)
        }
        
        // STEP 2: The Stomp (Hand smashes DOWN)
        if lowestFingerY > stompLine && isReady {
            triggerStomp()
        }
    }
    
    private func triggerStomp() {
        // 1. Lock it so they can't get multiple points for one stomp
        isReady = false
        
        // 2. Add SFX
        AudioManager.shared.playSFX("stomp")
        
        // 3. Instantly turn Green and add points!
        flashColor = .green
        hitCount += 1
        score += 15
        
        // 🚀 NOTICE: No more 'requiredHits' check!
        // The player just keeps stomping and racking up the score
        // until the GameDirector's timer runs out.
    }
}

// 🔧 PREVIEW SUPPORT
struct StompScene_Previews: PreviewProvider {
    static var previews: some View {
        StompScene(
            engine: TrackingEngine(),
            score: .constant(10),
            onComplete: { _ in }
        )
        .background(Color.black)
    }
}
