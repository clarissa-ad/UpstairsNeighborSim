import SwiftUI

struct AlarmTarget: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var isSnoozed: Bool = false
}

struct SnoozeScene: View {
    @ObservedObject var engine: TrackingEngine
    @Binding var score: Int
    var onWin: () -> Void
    
    // 🔧 Game State
    @State private var alarms: [AlarmTarget] = []
    @State private var hasWon: Bool = false
    @State private var currentMiniRound: Int = 1 // Tracks which of the 4 rounds we are in
    
    // 📐 Progressive Difficulty Math (Radius in pixels)
    // Round 1: 70px (Huge) -> Round 4: 25px (Tiny!)
    let roundThresholds: [CGFloat] = [70, 55, 40, 25]
    let requiredAlarms: Int = 3
    
    // Safely gets the current threshold based on the round
    var currentThreshold: CGFloat {
        let index = min(currentMiniRound - 1, roundThresholds.count - 1)
        return roundThresholds[index]
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 1. Background Text (Now shows the current level!)
                VStack {
                    Text(hasWon ? "SILENCE..." : "SNOOZE! (Lvl \(currentMiniRound))")
                        .font(.system(size: 60, weight: .black, design: .rounded))
                        .foregroundColor(hasWon ? .green : .white)
                        .shadow(color: .blue, radius: 10)
                    Spacer()
                }.padding(40)
                
                // 2. Draw the Dynamic Alarms
                ForEach(alarms) { alarm in
                    if !alarm.isSnoozed {
                        ZStack {
                            Circle()
                                .fill(Color.red)
                                // 🔧 VISUAL SCALING: The physical diameter shrinks alongside the math!
                                .frame(width: currentThreshold * 2, height: currentThreshold * 2)
                            
                            Image(systemName: "alarm.fill")
                                // The icon shrinks too
                                .font(.system(size: currentThreshold * 0.8))
                                .foregroundColor(.white)
                        }
                        .position(x: alarm.x * geo.size.width, y: alarm.y * geo.size.height)
                        .modifier(ShakeEffect(animatableData: CGFloat.random(in: 0...1) > 0.5 ? 1 : 0))
                        .animation(.default.repeatForever(autoreverses: true).speed(4), value: alarm.isSnoozed)
                        
                    } else {
                        Text("💤")
                            .font(.system(size: currentThreshold)) // Zzz's match the size
                            .position(x: alarm.x * geo.size.width, y: alarm.y * geo.size.height)
                    }
                }
            }
            .onAppear { setupAlarms() }
            .onChange(of: engine.hands) { _ in
                checkTaps(in: geo.size)
            }
        }
    }
    
    private func setupAlarms() {
        hasWon = false
        alarms = (0..<requiredAlarms).map { _ in
            AlarmTarget(
                x: CGFloat.random(in: 0.2...0.8),
                y: CGFloat.random(in: 0.3...0.8)
            )
        }
    }
    
    private func checkTaps(in size: CGSize) {
        guard !hasWon else { return }
        
        var snoozedSomethingThisFrame = false
        
        for hand in engine.hands {
            let handX = (1 - hand.indexTip.x) * size.width
            let handY = (1 - hand.indexTip.y) * size.height
            
            for i in alarms.indices {
                guard !alarms[i].isSnoozed else { continue }
                
                let alarmX = alarms[i].x * size.width
                let alarmY = alarms[i].y * size.height
                let distance = hypot(handX - alarmX, handY - alarmY)
                
                // 🔧 HIT MATH: We now check against the dynamically shrinking threshold!
                if distance < currentThreshold {
                    alarms[i].isSnoozed = true
                    score += 10
                    snoozedSomethingThisFrame = true
                }
            }
        }
        
        // 5. Check Win Condition
        if snoozedSomethingThisFrame {
            if alarms.allSatisfy({ $0.isSnoozed }) {
                hasWon = true
                
                if currentMiniRound < 4 {
                    // 📈 ADVANCE LEVEL: Spawn smaller alarms quickly!
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        currentMiniRound += 1
                        setupAlarms()
                    }
                } else {
                    // 🏆 CARTRIDGE COMPLETE: Tell the sandbox we won 4 rounds!
                    score += 50
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        onWin()
                        currentMiniRound = 1 // Reset back to massive Level 1
                        setupAlarms()
                    }
                }
            }
        }
    }
}

struct ShakeEffect: GeometryEffect {
    var animatableData: CGFloat
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: 10 * sin(animatableData * .pi * 2), y: 0))
    }
}
