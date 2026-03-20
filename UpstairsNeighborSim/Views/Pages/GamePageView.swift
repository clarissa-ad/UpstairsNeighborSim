import SwiftUI

struct GamePageView: View {
    @ObservedObject var engine: TrackingEngine
    @Binding var score: Int
    var onGameOver: () -> Void
    
    @StateObject private var director = GameDirector()
    
    var body: some View {
        VStack {
            // TOP: Score HUD (Stays exactly the same)
            HStack {
                Text("NOISE LEVEL: \(score)")
                    .font(.system(.title2, design: .monospaced).bold())
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(10)
                Spacer()
                Text("ROUND \(director.roundsPlayed)/\(director.maxRounds)")
                    .font(.headline)
                    .foregroundColor(.yellow)
            }.padding()
            
            Spacer()
            
            // MIDDLE: The Modular Cartridge Slot!
            Group {
                switch director.currentActivity {
                case .stomp:
                    // We pass the engine (for tracking), the score, and a way to tell the director we won!
                    StompScene(engine: engine, score: $score) {
                        director.pickNextActivity() // Skip to next game immediately if won early
                    }
                    
                // We will add the other 11 games here as we build them:
                // case .drum: DrumScene(...)
                // case .shake: ShakeScene(...)
                    
                default:
                    // A fallback just in case we haven't built the scene yet
                    Text("COMING SOON: \(director.currentActivity.rawValue)")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Gives the scene the whole middle area
            
            Spacer()
            
            // BOTTOM: The Panic Timer Bar (Stays exactly the same)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 30)
                    Rectangle()
                        .fill(director.timeRemaining > 1.5 ? Color.green : Color.red)
                        .frame(width: max(0, geo.size.width * (director.timeRemaining / director.timePerRound)), height: 30)
                        .animation(.linear(duration: 0.05), value: director.timeRemaining)
                }.cornerRadius(15)
            }.frame(height: 30).padding()
        }
        .onAppear { director.start() }
        .onChange(of: director.isGameOver) { isOver in
            if isOver { onGameOver() }
        }
    }
}
