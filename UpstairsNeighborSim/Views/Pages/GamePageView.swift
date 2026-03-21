import SwiftUI

struct GamePageView: View {
    @ObservedObject var engine: TrackingEngine
    @Binding var score: Int
    var onGameOver: () -> Void
    
    @StateObject private var director = GameDirector()
    
    var body: some View {
        VStack(spacing: 0) {
            
            // 1. TOP HUD: Instruction & Score
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(director.currentGame.instruction)
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundColor(.yellow)
                    
                    Text("NOISE: \(score)")
                        .font(.system(.title3, design: .monospaced).bold())
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.black.opacity(0.6))
                .cornerRadius(15)
                
                Spacer()
            }
            .padding()
            .zIndex(2)
            
            // 2. THE STAGE: The Switchboard
            Group {
                switch director.currentGame {
                case .stomp:
                    StompScene(engine: engine, score: $score, onComplete: { win in director.nextRound(success: win) })
                case .snooze:
                    SnoozeScene(engine: engine, score: $score, onComplete: { win in director.nextRound(success: win) })
                case .party:
                    PartyScene(engine: engine, score: $score, onComplete: { win in director.nextRound(success: win) })
                case .dj:
                    DJScene(engine: engine, score: $score, onComplete: { win in director.nextRound(success: win) })
                case .cymbals:
                    CymbalScene(engine: engine, score: $score, onComplete: { win in director.nextRound(success: win) })
                case .bonus:
                    BonusScene(engine: engine, score: $score, onComplete: { win in director.nextRound(success: win) })
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // 3. BOTTOM PANIC TIMER
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 25)
                    
                    Rectangle()
                        .fill(director.timeRemaining > 1.5 ? Color.green : Color.red)
                        .frame(width: max(0, geo.size.width * (director.timeRemaining / director.currentGame.timeLimit)), height: 25)
                        .animation(.linear(duration: 0.1), value: director.timeRemaining)
                }
                .cornerRadius(12.5)
            }
            .frame(height: 25)
            .padding()
        }
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            director.start()
        }
    }
}
