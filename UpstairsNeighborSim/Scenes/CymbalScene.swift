import SwiftUI

struct CymbalScene: View {
    @ObservedObject var engine: TrackingEngine
    @Binding var score: Int
    var onComplete: (Bool) -> Void // We keep this here so GamePageView doesn't error out
    
    // 🔧 Game State (No more limits!)
    @State private var currentCrashes: Int = 0
    
    // 📐 Math/Visual State
    @State private var lastDistance: CGFloat = 1000
    @State private var isClappedThisFrame: Bool = false
    @State private var flashColor: Color = .clear
    @State private var leftCymbalPos: CGPoint = CGPoint(x: 100, y: 300)
    @State private var rightCymbalPos: CGPoint = CGPoint(x: 300, y: 300)
    
    // ⚙️ Tuning Constants
    let crashThreshold: CGFloat = 120.0
    let minimumClapVelocity: CGFloat = 40.0
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 1. "Juice" Overlay
                flashColor.ignoresSafeArea()
                
                // 2. Score Attack UI (Shows them how many times they hit this round!)
                VStack {
                    Spacer()
                    Text("CRASHES: \(currentCrashes)!")
                        .font(.system(size: 50, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.bottom, 50)
                }
                
                // 3. DRAW THE CYMBALS
                drawCymbal(color: .orange, pos: leftCymbalPos, size: geo.size.width * 0.35)
                drawCymbal(color: .yellow, pos: rightCymbalPos, size: geo.size.width * 0.35)
                
            }
            .onChange(of: engine.hands) {
                updateCymbalLogic(in: geo.size)
            }
        }
    }
    
    // 🏗️ Visual Component Helper
    private func drawCymbal(color: Color, pos: CGPoint, size: CGFloat) -> some View {
        ZStack {
            Circle()
                .fill(RadialGradient(gradient: Gradient(colors: [color.opacity(0.8), Color.black.opacity(0.2)]), center: .center, startRadius: 5, endRadius: size/2))
                .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 4))
            
            Circle()
                .fill(Color.black.opacity(0.5))
                .frame(width: size * 0.2)
        }
        .frame(width: size, height: size)
        .rotationEffect(.degrees(isClappedThisFrame ? 5 : 0))
        .position(pos)
    }
    
    // 🧠 Core Logic
    private func updateCymbalLogic(in size: CGSize) {
        // We MUST have two hands to play cymbals
        guard engine.hands.count >= 2 else {
            isClappedThisFrame = false
            return
        }
        
        let hand1 = engine.hands[0]
        let hand2 = engine.hands[1]
        
        let leftHandPoint = CGPoint(
            x: (1 - hand1.indexTip.x) * size.width,
            y: (1 - hand1.indexTip.y) * size.height
        )
        let rightHandPoint = CGPoint(
            x: (1 - hand2.indexTip.x) * size.width,
            y: (1 - hand2.indexTip.y) * size.height
        )
        
        // UPDATE Visuals
        withAnimation(.interactiveSpring(response: 0.1, dampingFraction: 0.6)) {
            leftCymbalPos = leftHandPoint
            rightCymbalPos = rightHandPoint
        }
        
        // CLAP DETECTION MATH
        let dx = leftHandPoint.x - rightHandPoint.x
        let dy = leftHandPoint.y - rightHandPoint.y
        let currentDistance = hypot(dx, dy)
        
        let clapVelocity = lastDistance - currentDistance
        lastDistance = currentDistance
        
        // HIT DETECTION LOGIC
        if currentDistance < crashThreshold && clapVelocity > minimumClapVelocity {
            if !isClappedThisFrame {
                triggerCrasherHit()
            }
        } else if currentDistance > crashThreshold + 20 {
            isClappedThisFrame = false
        }
    }
    
    // 💥 The "Juice" Function
    private func triggerCrasherHit() {
        isClappedThisFrame = true
        
        AudioManager.shared.playSFX("cymbals") // Plays the sound instantly
        
        withAnimation(.easeIn(duration: 0.05)) {
            flashColor = .green.opacity(0.3)
            currentCrashes += 1 // Tally for this round
            score += 25 // RACK UP THOSE GLOBAL POINTS!
        }
        
        withAnimation(.easeOut(duration: 0.2).delay(0.05)) {
            flashColor = .clear
        }
        
        // 🚀 NOTICE WHAT IS MISSING:
        // We do NOT call onComplete() anymore.
        // The player just keeps spamming crashes to farm points
        // until the GameDirector's timer hits zero and pulls the plug!
    }
}

struct CymbalScene_Previews: PreviewProvider {
    static var previews: some View {
        CymbalScene(
            engine: TrackingEngine(),
            score: .constant(100),
            onComplete: { _ in }
        )
        .background(Color.black)
    }
}
