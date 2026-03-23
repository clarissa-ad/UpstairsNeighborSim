import SwiftUI

// 🔧 A cleaner list of scenes to test
enum DebugScene: String, CaseIterable {
    case stomp = "🥾 STOMP!"
    case snooze = "⏰ SNOOZE!"
    case dance = "💃 DANCE!"
    case dj = "🎧 DJ!"
    case cymbals = "🥁 CYMBALS!"
    case furniture = "🛏️ ROOM MAKEOVER!"
    case bonus = "6️⃣7️⃣ BONUS!"
}

struct DebugTrackerView: View {
    @ObservedObject var engine: TrackingEngine
    var onExit: () -> Void
    
    // Default immediately to Stomp for testing
    @State private var selectedScene: DebugScene = .stomp
    
    // Player 1 States
    @State private var mockScore: Int = 0
    @State private var winCount: Int = 0
    
    // ⚔️ Player 2 States (Multiplayer)
    @State private var isMultiplayerMode: Bool = false
    @State private var p2Score: Int = 0
    @State private var p2WinCount: Int = 0
    
    var body: some View {
        ZStack {
            // 1. THE STAGE (Automatically switches based on Toggle)
            if isMultiplayerMode {
                // ⚔️ SPLIT SCREEN
                HStack(spacing: 0) {
                    // PLAYER 1 (Left)
                    ZStack {
                        Color.blue.opacity(0.15).ignoresSafeArea() // Blue tint
                        renderScene(for: selectedScene, score: $mockScore, wins: $winCount, zone: .leftPlayer)
                    }
                    
                    // THE DIVIDER
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 4)
                        .ignoresSafeArea()
                    
                    // PLAYER 2 (Right)
                    ZStack {
                        Color.red.opacity(0.15).ignoresSafeArea() // Red tint
                        renderScene(for: selectedScene, score: $p2Score, wins: $p2WinCount, zone: .rightPlayer)
                    }
                }
            } else {
                // 🧍‍♂️ SOLO MODE
                renderScene(for: selectedScene, score: $mockScore, wins: $winCount, zone: .solo)
            }
            
            // 2. THE SANDBOX HUD
            VStack {
                // TOP BAR
                HStack {
                    Button("❌ EXIT SANDBOX", action: onExit)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    // 🔧 NEW: Multiplayer Toggle
                    Toggle("VS MODE", isOn: $isMultiplayerMode)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .frame(width: 200) // Keep it compact
                    
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
                
                // BOTTOM BAR (Scoreboard)
                HStack(spacing: 20) {
                    // PLAYER 1 HUD
                    VStack(spacing: 5) {
                        Text(isMultiplayerMode ? "P1 NOISE: \(mockScore)" : "NOISE UNITS: \(mockScore)")
                            .padding(.horizontal).padding(.vertical, 8)
                            .background(isMultiplayerMode ? Color.blue : Color.black.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        
                        Text("P1 STOMPS: \(winCount)")
                            .padding(.horizontal).padding(.vertical, 8)
                            .background(Color.green.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    // PLAYER 2 HUD (Only shows in VS Mode)
                    if isMultiplayerMode {
                        VStack(spacing: 5) {
                            Text("P2 NOISE: \(p2Score)")
                                .padding(.horizontal).padding(.vertical, 8)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            
                            Text("P2 STOMPS: \(p2WinCount)")
                                .padding(.horizontal).padding(.vertical, 8)
                                .background(Color.green.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                }
                .font(.headline)
            }
            .padding(30)
        }
        // Reset everything when swapping games
        .onChange(of: selectedScene) {
            mockScore = 0
            winCount = 0
            p2Score = 0
            p2WinCount = 0
        }
        .onChange(of: isMultiplayerMode) {
            mockScore = 0
            winCount = 0
            p2Score = 0
            p2WinCount = 0
        }
    }
    
    // 🏗️ HELPER: This draws the correct game and passes the data cleanly
    @ViewBuilder
    private func renderScene(for scene: DebugScene, score: Binding<Int>, wins: Binding<Int>, zone: PlayerZone) -> some View {
        switch scene {
        case .stomp:
            StompScene(engine: engine, score: score, playerZone: zone) { _ in wins.wrappedValue += 1 }
        case .snooze:
            SnoozeScene(engine: engine, score: score, playerZone: zone) { _ in wins.wrappedValue += 1 }
        case .dance:
            PartyScene(engine: engine, score: score, playerZone: zone) { _ in wins.wrappedValue += 1 }
        case .dj:
            DJScene(engine: engine, score: score, playerZone: zone) { _ in wins.wrappedValue += 1 }
        case .cymbals:
            CymbalScene(engine: engine, score: score, playerZone: zone) { _ in wins.wrappedValue += 1 }
        case .furniture:
            FurnitureScene(engine: engine, score: score, playerZone: zone) { _ in wins.wrappedValue += 1 }
        case .bonus:
            BonusScene(engine: engine, score: score, playerZone: zone) { _ in wins.wrappedValue += 1 }
        }
    }
}
