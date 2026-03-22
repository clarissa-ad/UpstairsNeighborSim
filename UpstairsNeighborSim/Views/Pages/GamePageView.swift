import SwiftUI

struct GamePageView: View {
    // accepts the engine from content view, not making a new one
    @ObservedObject var engine: TrackingEngine
    @StateObject private var director = GameDirector()
    
    // ⚙️ Game Settings (These will eventually be passed in from your Main Menu)
    var isMultiplayer: Bool
    var onReturnToMenu: () -> Void // Tells ContentView to go back to the start screen
    
    // 🏆 Global Score Trackers
    @State private var p1Score: Int = 0
    @State private var p2Score: Int = 0
    
    var body: some View {
        ZStack {
            // 🚦 TRAFFIC CONTROLLER: Which screen should we show?
            if director.isSequenceComplete {
                
                // 🏁 STATE B: THE GAME IS OVER -> Show Results
                ResultsPageView(
                    p1Score: p1Score,
                    p2Score: p2Score,
                    isMultiplayer: isMultiplayer,
                    onRematch: resetGame,
                    onMainMenu: {
                        // For now, just print. Later, this will dismiss back to the Main Menu!
                        print("Return to Main Menu")
                    }
                )
                
            } else {
                
                // 🎮 STATE A: THE GAME IS RUNNING -> Show the active games!
                if isMultiplayer {
                    // ⚔️ SPLIT SCREEN
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
                    // 🧍‍♂️ SOLO MODE
                    renderActiveGame(score: $p1Score, zone: .solo)
                }
                
                // ⏱️ THE HUD: Show instructions and the master clock on top of everything!
                gameHUD
            }
        }
        .onAppear {
            // Start the sequence the moment this screen loads
            director.start()
            // Make sure your engine starts its camera session here if it requires a manual start!
        }
    }
    
    // 🏗️ HELPER 1: The Switchboard (Exactly like the Practice Gym!)
    @ViewBuilder
    private func renderActiveGame(score: Binding<Int>, zone: PlayerZone) -> some View {
        // Notice that onComplete does nothing `{ _ in }`.
        // Because of your Infinite Score Attack upgrade, the GameDirector's timer
        // is the ONLY thing allowed to change the game!
        switch director.currentGame {
        case .stomp:
            StompScene(engine: engine, score: score, playerZone: zone) { _ in }
        case .snooze:
            SnoozeScene(engine: engine, score: score, playerZone: zone) { _ in }
        case .party:
            PartyScene(engine: engine, score: score, playerZone: zone) { _ in }
        case .dj:
            DJScene(engine: engine, score: score, playerZone: zone) { _ in }
        case .cymbals:
            CymbalScene(engine: engine, score: score, playerZone: zone) { _ in }
        case .bonus:
            BonusScene(engine: engine, score: score, playerZone: zone) { _ in }
        }
    }
    
    // ⏱️ HELPER 2: The Heads Up Display (Instructions & Timer)
    private var gameHUD: some View {
        VStack {
            // Instructions
            Text(director.currentGame.instruction)
                .font(.system(size: 60, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black, radius: 5)
                .padding(.top, 50)
            
            // The Master Clock
            Text(String(format: "%.1f", director.timeRemaining))
                .font(.system(size: 80, weight: .black, design: .monospaced))
                .foregroundColor(director.timeRemaining <= 2.0 ? .red : .white)
                .shadow(color: .black, radius: 5)
                // Add a heartbeat pulse when time is running out
                .scaleEffect(director.timeRemaining <= 2.0 ? 1.1 : 1.0)
                .animation(.linear(duration: 0.2).repeatForever(), value: director.timeRemaining <= 2.0)
            
            Spacer()
        }
        // Ignores safe area so it can float over the top of the screen cleanly
        .ignoresSafeArea()
    }
    
    // 🔄 HELPER 3: The Reset Button Logic
    private func resetGame() {
        p1Score = 0
        p2Score = 0
        director.start() // Tells the referee to reset the sequence and start the clock again
    }
}

// 🔧 PREVIEW
struct GamePageView_Previews: PreviewProvider {
    static var previews: some View {
        GamePageView(engine: TrackingEngine(), isMultiplayer: true, onReturnToMenu: {
            print ("Preview: Returned to Menu")
        })
    }
}
