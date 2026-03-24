import SwiftUI

// 🔧 A cleaner list of scenes to test
enum DebugScene: String, CaseIterable {
    case stomp = "🥾 STOMP!"
    case snooze = "⏰ SNOOZE!"
    case party = "💃 PARTY!"
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
    
    // 🧍‍♂️ Player 1 States
    @State private var mockScore: Int = 0
    @State private var winCount: Int = 0
    @State private var p1Progress: String = "" // Pipeline Catcher P1
    
    // ⚔️ Player 2 States (Multiplayer)
    @State private var isMultiplayerMode: Bool = false
    @State private var p2Score: Int = 0
    @State private var p2WinCount: Int = 0
    @State private var p2Progress: String = "" // Pipeline Catcher P2
    
    var body: some View {
        ZStack {
            // ==========================================
            // 1. THE STAGE (The Camera & Game Logic)
            // ==========================================
            if isMultiplayerMode {
                // ⚔️ SPLIT SCREEN
                HStack(spacing: 0) {
                    ZStack {
                        Color.blue.opacity(0.15).ignoresSafeArea()
                        renderScene(for: selectedScene, score: $mockScore, progressText: $p1Progress, wins: $winCount, zone: .leftPlayer)
                    }
                    Rectangle().fill(Color.white).frame(width: 4).ignoresSafeArea()
                    ZStack {
                        Color.red.opacity(0.15).ignoresSafeArea()
                        renderScene(for: selectedScene, score: $p2Score, progressText: $p2Progress, wins: $p2WinCount, zone: .rightPlayer)
                    }
                }
            } else {
                // 🧍‍♂️ SOLO MODE
                renderScene(for: selectedScene, score: $mockScore, progressText: $p1Progress, wins: $winCount, zone: .solo)
            }
            
            // ==========================================
            // 2. THE BEAUTIFUL SANDBOX HUD
            // ==========================================
            sandboxHUD
        }
        // Reset everything when swapping games or modes
        .onChange(of: selectedScene) {
            resetSandboxStates()
        }
        .onChange(of: isMultiplayerMode) {
            resetSandboxStates()
        }
    }
    
    // 🎨 THE REDESIGNED DEBUG HUD
    private var sandboxHUD: some View {
        ZStack(alignment: .top) {
            
            // 🛡️ GRADIENT SAFE ZONES (Top & Bottom for readability)
            VStack {
                LinearGradient(colors: [Color.black.opacity(0.85), Color.black.opacity(0.4), .clear], startPoint: .top, endPoint: .bottom)
                    .frame(height: 200)
                    .ignoresSafeArea(.all, edges: .top)
                Spacer()
                LinearGradient(colors: [.clear, Color.black.opacity(0.6), Color.black.opacity(0.9)], startPoint: .top, endPoint: .bottom)
                    .frame(height: 150)
                    .ignoresSafeArea(.all, edges: .bottom)
            }
            
            VStack(spacing: 0) {
                
                // --- 1. TOP BAR: DEBUG CONTROLS ---
                HStack {
                    // EXIT BUTTON
                    Button(action: onExit) {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                            Text("EXIT")
                        }
                        .font(.headline.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.red.opacity(0.8))
                        .clipShape(Capsule())
                    }
                    
                    Spacer()
                    
                    // SCENE PICKER
                    Picker("Test Scene", selection: $selectedScene) {
                        ForEach(DebugScene.allCases, id: \.self) { scene in
                            Text(scene.rawValue).tag(scene)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.black.opacity(0.7)))
                    .foregroundColor(.white)
                    .overlay(Capsule().stroke(Color.white.opacity(0.3), lineWidth: 1))
                    
                    Spacer()
                    
                    // MULTIPLAYER TOGGLE
                    Toggle("VS MODE", isOn: $isMultiplayerMode)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                        .font(.headline.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.black.opacity(0.7)))
                        .overlay(Capsule().stroke(Color.white.opacity(0.3), lineWidth: 1))
                        .frame(width: 180)
                }
                .padding(.horizontal, 30)
                .padding(.top, 10)
                
                // --- 2. THE HEADLINE & PIPELINE (From GamePageView) ---
                VStack(spacing: 5) {
                    Text(getActionWord(for: selectedScene))
                        .font(.system(size: 70, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .orange, radius: 15)
                        .rotationEffect(.degrees(-3))
                    
                    if isMultiplayerMode {
                        HStack(spacing: 60) {
                            if !p1Progress.isEmpty { progressPill(text: p1Progress, color: .blue) }
                            if !p2Progress.isEmpty { progressPill(text: p2Progress, color: .red) }
                        }
                    } else {
                        if !p1Progress.isEmpty { progressPill(text: p1Progress, color: .orange) }
                    }
                }
                .padding(.top, 10)
                
                Spacer() // Keeps the center clear!
                
                // --- 3. BOTTOM: SCORES & INSTRUCTIONS ---
                ZStack(alignment: .bottom) {
                    
                    // LEFT CORNER: P1 SCORES
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            scoreBadge(title: "SCORE", score: mockScore, color: .blue, icon: "star.fill")
                        }
                        Spacer()
                    }
                    
                    // RIGHT CORNER: P2 SCORES
                    if isMultiplayerMode {
                        HStack {
                            Spacer()
                            VStack(alignment: .trailing, spacing: 8) {
                                scoreBadge(title: "SCORE", score: p2Score, color: .red, icon: "star.fill")
                            }
                        }
                    }
                    
                    // DEAD CENTER: INSTRUCTION
                    Text(getInstruction(for: selectedScene))
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 25)
                        .padding(.vertical, 15)
                        .background(.ultraThinMaterial)
                        .environment(\.colorScheme, .dark)
                        .cornerRadius(20)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.3), lineWidth: 1))
                        .shadow(color: .black.opacity(0.3), radius: 10)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
    }
    
    // 🏗️ HELPER: Renders the active game
    @ViewBuilder
    private func renderScene(for scene: DebugScene, score: Binding<Int>, progressText: Binding<String>, wins: Binding<Int>, zone: PlayerZone) -> some View {
        switch scene {
        case .stomp: StompScene(engine: engine, score: score, progressText: progressText, playerZone: zone) { _ in wins.wrappedValue += 1 }
        case .snooze: SnoozeScene(engine: engine, score: score, progressText: progressText, playerZone: zone) { _ in wins.wrappedValue += 1 }
        case .party: PartyScene(engine: engine, score: score, progressText: progressText, playerZone: zone) { _ in wins.wrappedValue += 1 }
        case .dj: DJScene(engine: engine, score: score, progressText: progressText, playerZone: zone) { _ in wins.wrappedValue += 1 }
        case .cymbals: CymbalScene(engine: engine, score: score, progressText: progressText, playerZone: zone) { _ in wins.wrappedValue += 1 }
        case .furniture: FurnitureScene(engine: engine, score: score, progressText: progressText, playerZone: zone) { _ in wins.wrappedValue += 1 }
        case .bonus: BonusScene(engine: engine, score: score, progressText: progressText, playerZone: zone) { _ in wins.wrappedValue += 1 }
        }
    }
    
    // 🧹 HELPER: Resets all variables
    private func resetSandboxStates() {
        mockScore = 0
        winCount = 0
        p1Progress = ""
        p2Score = 0
        p2WinCount = 0
        p2Progress = ""
    }
    
    // ==========================================
    // 🎨 UI & LOGIC HELPERS (Mirrored from GamePageView)
    // ==========================================
    
    private func scoreBadge(title: String, score: Int, color: Color, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon).foregroundColor(color)
            Text("\(title): \(score)")
                .font(.system(size: 18, weight: .black, design: .monospaced))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Capsule().fill(.ultraThinMaterial).environment(\.colorScheme, .dark))
        .overlay(Capsule().stroke(color.opacity(0.8), lineWidth: 2))
        .shadow(color: color.opacity(0.3), radius: 5)
    }
    
    private func progressPill(text: String, color: Color) -> some View {
        Text(text)
            .font(.title2.bold())
            .foregroundColor(color)
            .padding(.horizontal, 15)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .environment(\.colorScheme, .dark)
            .cornerRadius(20)
    }
    
    private func getActionWord(for scene: DebugScene) -> String {
        switch scene {
        case .stomp: return "STOMP THE FLOOR!"
        case .snooze: return "WAKE UP!"
        case .party: return "IT'S A PARTY!"
        case .dj: return "DJ TIME!"
        case .cymbals: return "CYMBALS PRACTICE!"
        case .furniture: return "HOME RENO!"
        case .bonus: return "67 REDEMPTION!"
        }
    }
    
    private func getInstruction(for scene: DebugScene) -> String {
        switch scene {
        case .stomp: return "STOMP your foot past the line!"
        case .snooze: return "TAP the alarm clock as fast as you can!"
        case .party: return "WAVE your hands to the target!"
        case .dj: return "MOVE your hands left and right like a DJ!"
        case .cymbals: return "CLAP your hands together loudly!"
        case .furniture: return "PINCH the furniture and DRAG it away!"
        case .bonus: return "ALTERNATE PUMPING your arms up and down!"
        }
    }
}
