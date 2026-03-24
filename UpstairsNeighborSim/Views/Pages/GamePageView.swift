import SwiftUI

struct GamePageView: View {
    @ObservedObject var engine: TrackingEngine
    @StateObject private var director = GameDirector()
    
    var isMultiplayer: Bool
    var onReturnToMenu: () -> Void
    
    // 🏆 Global Score Trackers
    @State private var p1Score: Int = 0
    @State private var p2Score: Int = 0
    
    // 🪚 THE DATA PIPELINES (For dynamic mini-game text)
    @State private var p1Progress: String = ""
    @State private var p2Progress: String = ""
    
    var body: some View {
        ZStack {
            // 🚦 TRAFFIC CONTROLLER
            if director.isSequenceComplete {
                // 🏁 STATE B: THE GAME IS OVER
                ResultsPageView(
                    p1Score: p1Score,
                    p2Score: p2Score,
                    isMultiplayer: isMultiplayer,
                    onRematch: resetGame,
                    onMainMenu: onReturnToMenu
                )
            } else {
                // 🎮 STATE A: THE GAME IS RUNNING
                if isMultiplayer {
                    HStack(spacing: 0) {
                        ZStack {
                            Color.blue.opacity(0.15).ignoresSafeArea()
                            renderActiveGame(score: $p1Score, progressText: $p1Progress, zone: .leftPlayer)
                        }
                        Rectangle().fill(Color.white).frame(width: 4).ignoresSafeArea()
                        ZStack {
                            Color.red.opacity(0.15).ignoresSafeArea()
                            renderActiveGame(score: $p2Score, progressText: $p2Progress, zone: .rightPlayer)
                        }
                    }
                } else {
                    renderActiveGame(score: $p1Score, progressText: $p1Progress, zone: .solo)
                }
                
                // 🎨 THE NEW UNIVERSAL HUD OVERLAY
                universalGameHUD
                
                // ⏸️ THE PAUSE MENU
                if director.isPaused {
                    pauseMenuOverlay
                }
            }
        }
        .onAppear {
            director.start()
        }
    }
    
    // 🏗️ HELPER 1: The Switchboard
    @ViewBuilder
    private func renderActiveGame(score: Binding<Int>, progressText: Binding<String>, zone: PlayerZone) -> some View {
        // 🚀 ALL SCENES NOW USE THE STANDARDIZED PIPELINE CONTRACT
        switch director.currentGame {
        case .stomp:
            StompScene(engine: engine, score: score, progressText: progressText, playerZone: zone) { _ in }
        case .snooze:
            SnoozeScene(engine: engine, score: score, progressText: progressText, playerZone: zone) { _ in }
        case .party:
            PartyScene(engine: engine, score: score, progressText: progressText, playerZone: zone) { _ in }
        case .dj:
            DJScene(engine: engine, score: score, progressText: progressText, playerZone: zone) { _ in }
        case .cymbals:
            CymbalScene(engine: engine, score: score, progressText: progressText, playerZone: zone) { _ in }
        case .furniture:
            FurnitureScene(engine: engine, score: score, progressText: progressText, playerZone: zone) { _ in }
        case .bonus:
            BonusScene(engine: engine, score: score, progressText: progressText, playerZone: zone) { _ in }
        }
    }
    
    // 🎨 HELPER 2: The Redesigned Universal Heads Up Display
    private var universalGameHUD: some View {
        ZStack(alignment: .top) {
            
            // 🛡️ THE GRADIENT SAFE ZONE
            LinearGradient(
                colors: [Color.black.opacity(0.9), Color.black.opacity(0.4), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 200)
            .ignoresSafeArea(.all, edges: .top)
            
            VStack(spacing: 0) {
                
                // ==========================================
                // 1. THE MASTER DASHBOARD (TOP BAR)
                // ==========================================
                HStack(alignment: .top) {
                    
                    // 🏆 LEFT: ARCADE SCORE BADGES
                    VStack(alignment: .leading, spacing: 8) {
                        if isMultiplayer {
                            scoreBadge(title: "P1", score: p1Score, color: .blue, icon: "star.fill")
                            scoreBadge(title: "P2", score: p2Score, color: .red, icon: "star.fill")
                        } else {
                            scoreBadge(title: "SCORE", score: p1Score, color: .yellow, icon: "trophy.fill")
                        }
                    }
                    
                    Spacer()
                    
                    // ⏱️ MID-RIGHT: PROGRESS BARS
                    VStack(alignment: .trailing, spacing: 8) {
                        
                        // BAR 1: DYNAMIC GLOBAL SEQUENCE PROGRESS
                        HStack(spacing: 4) {
                            ForEach(0..<director.totalRounds, id: \.self) { index in
                                Capsule()
                                    .fill(index <= director.currentRoundIndex ? Color.yellow : Color.white.opacity(0.3))
                                    .frame(width: 15, height: 6)
                            }
                        }
                        
                        // BAR 2: MINI-GAME TIMER
                        GeometryReader { barGeo in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.white.opacity(0.2))
                                    .cornerRadius(8)
                                
                                Rectangle()
                                    .fill(director.timeRemaining <= 2.0 ? Color.red : Color.green)
                                    .cornerRadius(8)
                                    .frame(width: max(0, barGeo.size.width * (director.timeRemaining / director.currentGame.timeLimit)))
                                    .animation(.linear(duration: 0.1), value: director.timeRemaining)
                                
                                HStack {
                                    Spacer()
                                    Text(String(format: "%.1f", max(0, director.timeRemaining)))
                                        .font(.system(size: 16, weight: .black, design: .monospaced))
                                        .foregroundColor(.white)
                                        .shadow(color: .black, radius: 2)
                                        .padding(.trailing, 8)
                                }
                            }
                        }
                        .frame(width: 180, height: 24)
                    }
                    .padding(.trailing, 15)
                    
                    // ⏸️ FAR RIGHT: PAUSE BUTTON
                    Button(action: { director.pauseTimer() }) {
                        Image(systemName: "pause.circle.fill")
                            .font(.system(size: 45))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 5)
                    }
                }
                .padding(.horizontal, 25)
                .padding(.top, 5)
                
                // ==========================================
                // 2. THE HEADLINE & PIPELINE (UPPER-MID)
                // ==========================================
                VStack(spacing: 5) {
                    // A. THE GIANT ACTION WORD
                    Text(getActionWord())
                        .font(.system(size: 70, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .orange, radius: 15)
                        .rotationEffect(.degrees(-3))
                    
                    // B. The Data Pipeline Texts
                    if isMultiplayer {
                        HStack(spacing: 60) {
                            if !p1Progress.isEmpty { progressPill(text: p1Progress, color: .blue) }
                            if !p2Progress.isEmpty { progressPill(text: p2Progress, color: .red) }
                        }
                    } else {
                        if !p1Progress.isEmpty { progressPill(text: p1Progress, color: .orange) }
                    }
                }
                .padding(.top, -15)
                
                Spacer()
                
                // ==========================================
                // 3. DEAD CENTER INSTRUCTIONS (BOTTOM)
                // ==========================================
                HStack {
                    Spacer()
                    
                    Text(getInstruction())
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 25)
                        .padding(.vertical, 15)
                        .background(.ultraThinMaterial)
                        .environment(\.colorScheme, .dark)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.3), radius: 10)
                    
                    Spacer()
                }
                .padding(.bottom, 40)
            }
        }
    }
    
    // 🎨 UI HELPER: The Arcade Score Badge
    private func scoreBadge(title: String, score: Int, color: Color, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
            
            Text("\(title): \(score)")
                .font(.system(size: 20, weight: .black, design: .monospaced))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Capsule().fill(.ultraThinMaterial).environment(\.colorScheme, .dark))
        .overlay(Capsule().stroke(color.opacity(0.8), lineWidth: 2))
        .shadow(color: color.opacity(0.3), radius: 5)
    }
    
    // 🎨 UI HELPER: Reusable styling for the mini-game text
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
    
    // 🧠 LOGIC HELPER: Standardized English Action Words
    private func getActionWord() -> String {
        switch director.currentGame {
        case .stomp: return "STOMP!"
        case .snooze: return "WAKE UP!"
        case .party: return "WAVE!"
        case .dj: return "SCRATCH!"
        case .cymbals: return "CLAP!"
        case .furniture: return "PULL!"
        case .bonus: return "PUMP IT!"
        }
    }
    
    // 🧠 LOGIC HELPER: Standardized English Instructions
    private func getInstruction() -> String {
        switch director.currentGame {
        case .stomp: return "Stomp your foot past the line!"
        case .snooze: return "Hit the alarm clock as fast as you can!"
        case .party: return "Wave your hands to the target!"
        case .dj: return "Move your hands left and right like a DJ!"
        case .cymbals: return "Clap your hands together loudly!"
        case .furniture: return "Pinch the chair and drag it away!"
        case .bonus: return "Alternate pumping your arms up and down!"
        }
    }
    
    // ⏸️ HELPER 3: The Pause Menu
    private var pauseMenuOverlay: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("PAUSED")
                    .font(.system(size: 60, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.bottom, 20)
                
                Button(action: { director.resumeTimer() }) {
                    Text("▶️ RESUME")
                        .font(.title.bold())
                        .foregroundColor(.white)
                        .frame(width: 250)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(15)
                }
                
                Button(action: { director.forceEndGame() }) {
                    Text("🛑 END GAME")
                        .font(.title.bold())
                        .foregroundColor(.white)
                        .frame(width: 250)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(15)
                }
            }
        }
    }
    
    // 🔄 HELPER 4: The Reset Button Logic
    private func resetGame() {
        p1Score = 0
        p2Score = 0
        director.start()
    }
}
