import SwiftUI

// 1. The Dynamic Alarm Model
struct AlarmTarget: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var radius: CGFloat
    var isSnoozed: Bool = false
}

struct SnoozeScene: View {
    // 🔧 STANDARD CONTRACT
    @ObservedObject var engine: TrackingEngine
    @Binding var score: Int
    @Binding var progressText: String // ⬅️ THE NEW DATA PIPELINE
    
    var playerZone: PlayerZone = .solo
    var onComplete: (Bool) -> Void
    
    // 🔧 Infinite Game State
    @State private var alarms: [AlarmTarget] = []
    @State private var totalSnoozes: Int = 0
    @State private var isShaking: Bool = false // 🔧 Much smoother animation state
    
    let maxAlarmsOnScreen = 4
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 2. Draw the Alarms (NO TEXT HUD!)
                ForEach(alarms) { alarm in
                    ZStack {
                        Circle()
                            .fill(Color.red)
                            .frame(width: alarm.radius * 2, height: alarm.radius * 2)
                            .shadow(color: .black.opacity(0.5), radius: 5)
                        
                        Image(systemName: "alarm.fill")
                            .font(.system(size: alarm.radius * 0.8))
                            .foregroundColor(.white)
                    }
                    .position(x: alarm.x * geo.size.width, y: alarm.y * geo.size.height)
                    // 🔧 A much cleaner, crash-proof shake animation
                    .rotationEffect(.degrees(isShaking ? 5 : -5))
                    .animation(
                        .easeInOut(duration: 0.1).repeatForever(autoreverses: true),
                        value: isShaking
                    )
                }
            }
            .onAppear {
                isShaking = true // Start the shake instantly
                for _ in 0..<maxAlarmsOnScreen {
                    alarms.append(generateRandomAlarm())
                }
                // 🚀 Initialize the pipeline text!
                progressText = "SNOOZED: \(totalSnoozes)"
            }
            .onChange(of: engine.hands) {
                checkTaps(in: geo.size)
            }
        }
    }
    
    // 🔧 FIX 1: The "Safe Zone" Spawn
    // We clamp the random generation closer to the center so hands don't clip out of the camera!
    private func generateRandomAlarm() -> AlarmTarget {
        return AlarmTarget(
            x: CGFloat.random(in: 0.20...0.80),
            // ⬇️ Pushed down to 0.35 so it doesn't overlap the new master dashboard!
            y: CGFloat.random(in: 0.35...0.70),
            radius: CGFloat.random(in: 35...65)
        )
    }
    
    private func checkTaps(in size: CGSize) {
        // 🛑 FIX 2: MULTIPLAYER FILTER
        let validHands = engine.hands.filter {
            CoordinateMapper.belongsToZone(rawX: $0.indexTip.x, zone: playerZone)
        }
        
        var newAlarms = alarms
        var snoozedCountThisFrame = 0
        
        for hand in validHands {
            // 🎯 FIX 3: THE UNIVERSAL LENS
            let handPoint = CoordinateMapper.localPoint(rawPoint: hand.indexTip, zone: playerZone, screenSize: size)
            
            for i in newAlarms.indices {
                let alarmX = newAlarms[i].x * size.width
                let alarmY = newAlarms[i].y * size.height
                let distance = hypot(handPoint.x - alarmX, handPoint.y - alarmY)
                
                // 💡 FIX 4: The Hitbox Buffer!
                // We add 40 invisible pixels of forgiveness to the radius so fast swipes register.
                if distance < (newAlarms[i].radius + 40) && !newAlarms[i].isSnoozed {
                    newAlarms[i].isSnoozed = true
                    snoozedCountThisFrame += 1
                }
            }
        }
        
        // If we successfully hit something...
        if snoozedCountThisFrame > 0 {
            AudioManager.shared.playSFX("snooze")
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                totalSnoozes += snoozedCountThisFrame
                score += (10 * snoozedCountThisFrame)
                
                // 🚀 PIPELINE UPDATE: Feed data to the top dashboard!
                progressText = "SNOOZED: \(totalSnoozes)"
                
                newAlarms.removeAll { $0.isSnoozed }
                
                for _ in 0..<snoozedCountThisFrame {
                    newAlarms.append(generateRandomAlarm())
                }
                
                alarms = newAlarms
            }
        }
    }
}

// 🔧 PREVIEW SUPPORT
struct SnoozeScene_Previews: PreviewProvider {
    static var previews: some View {
        SnoozeScene(
            engine: TrackingEngine(),
            score: .constant(0),
            progressText: .constant("SNOOZED: 0"),
            onComplete: { _ in }
        )
        .background(Color.black)
    }
}
