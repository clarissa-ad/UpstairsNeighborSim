import SwiftUI

struct BonusScene: View {
    @ObservedObject var engine: TrackingEngine
    @Binding var score: Int
    var playerZone: PlayerZone = .solo
    var onComplete: (Bool) -> Void
    
    // 🔧 Game State
    @State private var pumps: Int = 0
    @State private var leftIsDown: Bool = true
    @State private var rightIsDown: Bool = true
    @State private var flashColor: Color = .clear
    
    // 📐 The Math (Y: 0.0 is top of screen, Y: 1.0 is bottom)
    let liftLine: CGFloat = 0.7  // Hand must go above top 35%
    let resetLine: CGFloat = 0.3 // Hand must drop below bottom 65%
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 1. Gold/Neon Flash Background
                flashColor.ignoresSafeArea()
                
                // 2. The HUD
                VStack {
                    Text("REDEMPTION!")
                        .font(.system(size: 55, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .orange, radius: 15)
                        .padding(.top, 20)
                    
                    Text("PUMP IT: \(pumps)!")
                        .font(.system(size: 40, weight: .bold, design: .monospaced))
                        .foregroundColor(.yellow)
                    
                    Spacer()
                    
                    Text("ANGKAT BERGANTIAN! (ALTERNATE!)")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding(.bottom, 40)
                }
                .zIndex(2)
                
                // 3. Visual Guide Lines (Optional, but helps players understand)
                VStack(spacing: 0) {
                    Rectangle().fill(Color.green.opacity(0.2)).frame(height: geo.size.height * liftLine)
                    Spacer()
                    Rectangle().fill(Color.red.opacity(0.2)).frame(height: geo.size.height * (1 - resetLine))
                }
            }
            .onChange(of: engine.hands) {
                checkAlternatingPump()
            }
        }
    }
    
    private func checkAlternatingPump() {
        // 🛑 1. FILTER: Ignore the other player
        let validHands = engine.hands.filter { CoordinateMapper.belongsToZone(rawX: $0.indexTip.x, zone: playerZone) }
        
        // 2. Check validHands instead of engine.hands
        guard validHands.count >= 2 else { return }
        
        let hand1 = validHands[0]
        let hand2 = validHands[1]
        
        let leftHand = hand1.indexTip.x > hand2.indexTip.x ? hand1 : hand2
        let rightHand = hand1.indexTip.x > hand2.indexTip.x ? hand2 : hand1
        
        // Process Left Hand
        if leftHand.indexTip.y < liftLine && leftIsDown {
            leftIsDown = false
            triggerPump()
        } else if leftHand.indexTip.y > resetLine && !leftIsDown {
            leftIsDown = true
        }
        
        // Process Right Hand
        if rightHand.indexTip.y < liftLine && rightIsDown {
            rightIsDown = false
            triggerPump()
        } else if rightHand.indexTip.y > resetLine && !rightIsDown {
            rightIsDown = true
        }
    }
    
    private func triggerPump() {
        AudioManager.shared.playSFX("whoosh") // Or a coin sound!
        
        withAnimation(.easeIn(duration: 0.05)) {
            pumps += 1
            score += 30 // Bonus stages give massive points!
            flashColor = .yellow.opacity(0.4)
        }
        
        withAnimation(.easeOut(duration: 0.2).delay(0.05)) {
            flashColor = .clear
        }
    }
}

// 🔧 PREVIEW
struct BonusScene_Previews: PreviewProvider {
    static var previews: some View {
        BonusScene(engine: TrackingEngine(), score: .constant(500), onComplete: { _ in })
            .background(Color.black)
    }
}
