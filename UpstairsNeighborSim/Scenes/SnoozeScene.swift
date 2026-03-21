import SwiftUI

// 1. The Dynamic Alarm Model
struct AlarmTarget: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var radius: CGFloat // 🔧 NEW: Every alarm has a random size!
    var isSnoozed: Bool = false
}

struct SnoozeScene: View {
    @ObservedObject var engine: TrackingEngine
    @Binding var score: Int
    var onComplete: (Bool) -> Void // Kept for the GamePageView contract
    
    // 🔧 Infinite Game State
    @State private var alarms: [AlarmTarget] = []
    @State private var totalSnoozes: Int = 0
    
    // How many alarms should be on screen at the exact same time?
    let maxAlarmsOnScreen = 4
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 1. Background HUD
                VStack {
                    Text("MATIKAN ALARM!")
                        .font(.system(size: 50, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .blue, radius: 10)
                    
                    Text("SNOOZES: \(totalSnoozes)!")
                        .font(.title.bold())
                        .foregroundColor(.yellow)
                    
                    Spacer()
                }
                .padding(40)
                .zIndex(2) // Keep text on top
                
                // 2. Draw the Alarms
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
                    // The shake animation makes them look highly annoying
                    .modifier(ShakeEffect(animatableData: CGFloat.random(in: 0...1) > 0.5 ? 1 : 0))
                    .animation(.default.repeatForever(autoreverses: true).speed(4), value: alarm.isSnoozed)
                }
            }
            .onAppear {
                // Spawn the initial batch of alarms
                for _ in 0..<maxAlarmsOnScreen {
                    alarms.append(generateRandomAlarm())
                }
            }
            .onChange(of: engine.hands) {
                checkTaps(in: geo.size)
            }
        }
    }
    
    // 🔧 Helper: Spawns an alarm anywhere, at any size
    private func generateRandomAlarm() -> AlarmTarget {
        return AlarmTarget(
            x: CGFloat.random(in: 0.15...0.85), // Keep away from extreme edges
            y: CGFloat.random(in: 0.25...0.85),
            radius: CGFloat.random(in: 30...70) // Tiny (30px) to Huge (70px)
        )
    }
    
    private func checkTaps(in size: CGSize) {
        var newAlarms = alarms // Copy the array to safely modify it
        var snoozedCountThisFrame = 0
        
        for hand in engine.hands {
            let handX = (1 - hand.indexTip.x) * size.width
            let handY = (1 - hand.indexTip.y) * size.height
            
            // Check every alarm on screen
            for i in newAlarms.indices {
                let alarmX = newAlarms[i].x * size.width
                let alarmY = newAlarms[i].y * size.height
                let distance = hypot(handX - alarmX, handY - alarmY)
                
                // 🎯 HIT MATH: Did the hand touch this specific alarm's random radius?
                if distance < newAlarms[i].radius && !newAlarms[i].isSnoozed {
                    newAlarms[i].isSnoozed = true
                    snoozedCountThisFrame += 1
                }
            }
        }
        
        // If we successfully hit something this exact frame...
        if snoozedCountThisFrame > 0 {
            AudioManager.shared.playSFX("snooze")
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                totalSnoozes += snoozedCountThisFrame
                score += (10 * snoozedCountThisFrame)
                
                // 1. Delete the alarms we just hit
                newAlarms.removeAll { $0.isSnoozed }
                
                // 2. Instantly spawn new ones to replace them!
                for _ in 0..<snoozedCountThisFrame {
                    newAlarms.append(generateRandomAlarm())
                }
                
                // 3. Update the screen
                alarms = newAlarms
            }
        }
    }
}

// 🔧 Required for the Shake Animation
struct ShakeEffect: GeometryEffect {
    var animatableData: CGFloat
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: 10 * sin(animatableData * .pi * 2), y: 0))
    }
}

// 🔧 PREVIEW SUPPORT
struct SnoozeScene_Previews: PreviewProvider {
    static var previews: some View {
        SnoozeScene(
            engine: TrackingEngine(),
            score: .constant(0),
            onComplete: { _ in }
        )
        .background(Color.black)
    }
}
