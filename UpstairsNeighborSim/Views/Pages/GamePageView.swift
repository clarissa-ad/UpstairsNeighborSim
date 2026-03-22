import SwiftUI

struct GamePageView: View {
    @ObservedObject var engine: TrackingEngine
    @StateObject private var director = GameDirector()
    
    var isMultiplayer: Bool
    var onReturnToMenu: () -> Void
    
    // These variables ALREADY track the total overall score!
    @State private var p1Score: Int = 0
    @State private var p2Score: Int = 0
    
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
                            renderActiveGame(score: $p1Score, zone: .leftPlayer)
                        }
                        Rectangle().fill(Color.white).frame(width: 4).ignoresSafeArea()
                        ZStack {
                            Color.red.opacity(0.15).ignoresSafeArea()
                            renderActiveGame(score: $p2Score, zone: .rightPlayer)
                        }
                    }
                } else {
                    renderActiveGame(score: $p1Score, zone: .solo)
                }
                
                // ⏱️ THE HUD
                gameHUD
                
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
    private func renderActiveGame(score: Binding<Int>, zone: PlayerZone) -> some View {
        switch director.currentGame {
        case .stomp: StompScene(engine: engine, score: score, playerZone: zone) { _ in }
        case .snooze: SnoozeScene(engine: engine, score: score, playerZone: zone) { _ in }
        case .party: PartyScene(engine: engine, score: score, playerZone: zone) { _ in }
        case .dj: DJScene(engine: engine, score: score, playerZone: zone) { _ in }
        case .cymbals: CymbalScene(engine: engine, score: score, playerZone: zone) { _ in }
        case .bonus: BonusScene(engine: engine, score: score, playerZone: zone) { _ in }
        }
    }
    
    // ⏱️ HELPER 2: The Redesigned Heads Up Display
    private var gameHUD: some View {
        VStack(spacing: 0) {
            // TOP BAR: Scores, Instruction & Pause Button
            ZStack(alignment: .top) {
                
                // CENTER: The Current Game Instruction
                Text(director.currentGame.instruction)
                    .font(.system(size: 50, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 5)
                
                // SIDES: Scoreboard (Left) and Pause (Right)
                HStack(alignment: .top) {
                    
                    // 🏆 NEW: THE SCORE TRACKER
                    VStack(alignment: .leading, spacing: 5) {
                        if isMultiplayer {
                            Text("P1: \(p1Score)")
                                .foregroundColor(.blue)
                            Text("P2: \(p2Score)")
                                .foregroundColor(.red)
                        } else {
                            Text("TOTAL: \(p1Score)")
                                .foregroundColor(.white)
                        }
                    }
                    .font(.title2.bold().monospaced())
                    .padding(12)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(10)
                    
                    Spacer()
                    
                    // ⏸️ PAUSE BUTTON
                    Button(action: { director.pauseTimer() }) {
                        Image(systemName: "pause.circle.fill")
                            .font(.system(size: 45))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 5)
                    }
                }
            }
            .padding(.horizontal, 30)
            .padding(.top, 20)
            
            // TIMER PROGRESS BAR
            GeometryReader { barGeo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.black.opacity(0.5))
                        .cornerRadius(6)
                    
                    Rectangle()
                        .fill(director.timeRemaining <= 2.0 ? Color.red : Color.green)
                        .cornerRadius(6)
                        .frame(width: max(0, barGeo.size.width * (director.timeRemaining / director.currentGame.timeLimit)))
                        .animation(.linear(duration: 0.1), value: director.timeRemaining)
                }
            }
            .frame(height: 12)
            .padding(.horizontal, 30)
            .padding(.top, 10)
            
            Spacer()
            
            // BOTTOM RIGHT COUNTER
            HStack {
                Spacer()
                Text(String(format: "%.1f", max(0, director.timeRemaining)))
                    .font(.system(size: 30, weight: .bold, design: .monospaced))
                    .foregroundColor(director.timeRemaining <= 2.0 ? .red : .white)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(10)
                    .padding(.trailing, 30)
                    .padding(.bottom, 30)
            }
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

// 🔧 PREVIEW
struct GamePageView_Previews: PreviewProvider {
    static var previews: some View {
        GamePageView(engine: TrackingEngine(), isMultiplayer: true, onReturnToMenu: {})
    }
}
