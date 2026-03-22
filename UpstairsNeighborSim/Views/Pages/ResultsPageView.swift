import SwiftUI

struct ResultsPageView: View {
    // 🔧 SUSTAINABLE DATA INJECTION
    // The view just accepts these facts and doesn't care where they came from
    let p1Score: Int
    let p2Score: Int
    let isMultiplayer: Bool
    
    // Callbacks to let the parent view handle the navigation
    let onRematch: () -> Void
    let onMainMenu: () -> Void
    
    // 🎬 Animation States
    @State private var displayedP1Score: Int = 0
    @State private var displayedP2Score: Int = 0
    @State private var showButtons: Bool = false
    
    var body: some View {
        ZStack {
            // 1. Background
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                
                // 2. Header
                VStack(spacing: 10) {
                    Text("CHAOS COMPLETE!")
                        .font(.system(size: 50, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .red, radius: 10)
                    
                    Text(getWinnerText())
                        .font(.title2.bold())
                        .foregroundColor(.yellow)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // 3. The Scoreboard (Adapts to Solo or VS Mode!)
                HStack(spacing: 40) {
                    // PLAYER 1 SCORECARD
                    ScoreCardView(
                        title: isMultiplayer ? "PLAYER 1" : "FINAL SCORE",
                        score: displayedP1Score,
                        color: .blue,
                        rank: calculateRank(score: p1Score)
                    )
                    
                    // PLAYER 2 SCORECARD (Only shows in VS Mode)
                    if isMultiplayer {
                        ScoreCardView(
                            title: "PLAYER 2",
                            score: displayedP2Score,
                            color: .red,
                            rank: calculateRank(score: p2Score)
                        )
                    }
                }
                
                Spacer()
                
                // 4. Navigation Buttons (Fades in after scores tally)
                if showButtons {
                    VStack(spacing: 20) {
                        Button(action: onRematch) {
                            Text("🔄 PLAY AGAIN")
                                .font(.title.bold())
                                .foregroundColor(.white)
                                .frame(maxWidth: 300)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(15)
                        }
                        
                        Button(action: onMainMenu) {
                            Text("🏠 MAIN MENU")
                                .font(.title3.bold())
                                .foregroundColor(.white)
                                .frame(maxWidth: 300)
                                .padding()
                                .background(Color.gray.opacity(0.5))
                                .cornerRadius(15)
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
                
                Spacer()
            }
        }
        .onAppear {
            animateScores()
        }
    }
    
    // 🧠 HELPER: Determines the winner text
    private func getWinnerText() -> String {
        if !isMultiplayer { return "THE NEIGHBORS HATE YOU." }
        if p1Score > p2Score { return "PLAYER 1 IS THE WORST NEIGHBOR!" }
        if p2Score > p1Score { return "PLAYER 2 IS THE WORST NEIGHBOR!" }
        return "IT'S A TIE! EVERYONE LOSES!"
    }
    
    // 🧠 HELPER: Gives them a funny title based on their score
    private func calculateRank(score: Int) -> String {
        switch score {
        case 0...200: return "Polite Ghost 👻"
        case 201...500: return "Mild Annoyance 🐭"
        case 501...1000: return "Public Nuisance 📢"
        default: return "MENACE TO SOCIETY 👹"
        }
    }
    
    // 🎬 HELPER: The Tally Animation
    private func animateScores() {
        // Play a drumroll sound here!
        AudioManager.shared.playSFX("drumroll")
        
        withAnimation(.easeOut(duration: 2.0)) {
            displayedP1Score = p1Score
            displayedP2Score = p2Score
        }
        
        // Show the buttons after the score finishes counting up
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.spring()) {
                showButtons = true
                // Play a crash/cheer sound here!
                AudioManager.shared.playSFX("cymbals")
            }
        }
    }
}

// 🏗️ SUB-VIEW: Keeps the code clean and reusable
struct ScoreCardView: View {
    let title: String
    let score: Int
    let color: Color
    let rank: String
    
    var body: some View {
        VStack(spacing: 15) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
            
            Text("\(score)")
                .font(.system(size: 70, weight: .black, design: .monospaced))
                .foregroundColor(color)
                // Adds a cool glow effect
                .shadow(color: color.opacity(0.5), radius: 10)
            
            Text(rank)
                .font(.title3.bold())
                .foregroundColor(.white)
                .padding(.top, 10)
        }
        .padding(30)
        .background(Color.white.opacity(0.1))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(color, lineWidth: 4)
        )
    }
}

// 🔧 PREVIEW SUPPORT
struct ResultsPageView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsPageView(
            p1Score: 1250,
            p2Score: 840,
            isMultiplayer: true,
            onRematch: { print("Rematch hit") },
            onMainMenu: { print("Menu hit") }
        )
    }
}
