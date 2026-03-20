import SwiftUI

struct GamePageView: View {
    @ObservedObject var engine: TrackingEngine
    @Binding var score: Int
    var onGameOver: () -> Void
    
    @StateObject private var director = GameDirector()
    
    var body: some View {
        VStack(spacing: 0) {
            // TOP HUD
            HStack {
                Text("NOISE: \(score)")
                    .font(.system(.title2, design: .monospaced).bold())
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(10)
                
                Spacer()
                
                Text("ROUND \(director.roundsPlayed)/\(director.maxRounds)")
                    .font(.headline)
                    .foregroundColor(.yellow)
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(10)
            }
            .padding()
            .zIndex(2) // Keeps HUD above the games
            
            // THE STAGE (Loads the specific game)
            Group {
                switch director.currentGame {
                case .stomp:
                    StompScene(engine: engine, score: $score) {
                        director.pickNextActivity()
                    }
                case .snooze:
                    SnoozeScene(engine: engine, score: $score) {
                        director.pickNextActivity()
                    }
                case .party:
                    PartyScene(engine: engine, score: $score) {
                        director.pickNextActivity()
                    }
                case .dj:
                    DJScene(engine: engine, score: $score) {
                        director.pickNextActivity()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // BOTTOM PANIC TIMER
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 30)
                    
                    Rectangle()
                        .fill(director.timeRemaining > 2.0 ? Color.green : Color.red)
                        .frame(width: max(0, geo.size.width * (director.timeRemaining / director.timePerRound)), height: 30)
                        .animation(.linear(duration: 0.05), value: director.timeRemaining)
                }
                .cornerRadius(15)
            }
            .frame(height: 30)
            .padding()
        }
        .onAppear { director.start() }
        .onChange(of: director.isGameOver) {
            if director.isGameOver { onGameOver() }
        }
    }
}
