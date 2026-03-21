import SwiftUI

// 🔧 A cleaner list of scenes to test
enum DebugScene: String, CaseIterable {
    case stomp = "🥾 STOMP!"
    case snooze = "⏰ SNOOZE!"
    case dance = "💃 DANCE!"
    case dj = "🎧 DJ!"
    case cymbals = "🥁 CYMBALS!"
    case bonus = "6️⃣7️⃣ BONUS!"
}

struct DebugTrackerView: View {
    @ObservedObject var engine: TrackingEngine
    var onExit: () -> Void
    
    // Default immediately to Stomp for testing
    @State private var selectedScene: DebugScene = .stomp
    @State private var mockScore: Int = 0
    @State private var winCount: Int = 0
    
    var body: some View {
        ZStack {
            // 1. Load the Selected Scene (ContentView handles the dots on top of this)
            switch selectedScene {
            case .stomp:
                StompScene(engine: engine, score: $mockScore) { _ in
                    winCount += 1
                }
            case .snooze:
                SnoozeScene(engine: engine, score: $mockScore) { _ in
                    winCount += 1
                }
            case .dance:
                PartyScene(engine: engine, score: $mockScore){ _ in
                    winCount += 1
                }
            case .dj:
                DJScene(engine: engine, score: $mockScore){ _ in
                    winCount += 1
                }
            case .cymbals:
                CymbalScene(engine: engine, score: $mockScore){ _ in
                    winCount += 1
                }
            case .bonus:
                BonusScene(engine: engine, score: $mockScore){ _ in
                    winCount += 1
                }
            }
            
            // 2. The Sandbox HUD (Moved to top of ZStack to be clickable)
            VStack {
                HStack {
                    Button("❌ EXIT SANDBOX", action: onExit)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    Picker("Test Scene", selection: $selectedScene) {
                        ForEach(DebugScene.allCases, id: \.self) { scene in
                            Text(scene.rawValue).tag(scene)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                Spacer()
                
                // Mock Scoreboard
                HStack {
                    Text("NOISE UNITS: \(mockScore)")
                        .padding()
                        .background(Color.black.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    
                    Text("SUCCESSFUL STOMPS: \(winCount)")
                        .padding()
                        .background(Color.green.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(30)
        }
        .onChange(of: selectedScene) {
            mockScore = 0
            winCount = 0
        }
    }
}
