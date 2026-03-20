import SwiftUI

struct DJScene: View {
    @ObservedObject var engine: TrackingEngine
    @Binding var score: Int
    var onWin: () -> Void
    
    // 🔧 Game State
    @State private var hypeLevel: CGFloat = 0.0
    @State private var previousPositions: [CGFloat] = []
    @State private var hasWon: Bool = false
    
    // 📐 The Math: They must move their hands a combined total of 8 "screen widths"
    let requiredHype: CGFloat = 8.0
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 1. Instructions & Hype Meter
                VStack {
                    Text(hasWon ? "DROP THE BASS!" : "NGE-DJ!")
                        .font(.system(size: 60, weight: .black, design: .rounded))
                        .foregroundColor(hasWon ? .green : .white)
                        .shadow(color: .purple, radius: 10)
                    
                    // The Hype Progress Bar
                    GeometryReader { barGeo in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 30)
                            
                            Rectangle()
                                .fill(LinearGradient(colors: [.purple, .cyan], startPoint: .leading, endPoint: .trailing))
                                .frame(width: min(barGeo.size.width, barGeo.size.width * (hypeLevel / requiredHype)), height: 30)
                                .animation(.linear(duration: 0.1), value: hypeLevel)
                        }
                        .cornerRadius(15)
                    }
                    .frame(height: 30)
                    .padding(.horizontal, 40)
                    
                    // Warning if hands are missing
                    if engine.hands.count < 2 && !hasWon {
                        Text("⚠️ PUT BOTH HANDS UP! ⚠️")
                            .font(.title.bold())
                            .foregroundColor(.red)
                            .padding(.top, 10)
                    }
                    
                    Spacer()
                }
                .padding(40)
                
                // 2. The Visual DJ Decks
                HStack(spacing: geo.size.width * 0.2) {
                    DJDeckView(hype: hypeLevel, isActive: engine.hands.count == 2)
                    DJDeckView(hype: hypeLevel, isActive: engine.hands.count == 2)
                }
                .position(x: geo.size.width / 2, y: geo.size.height * 0.6)
            }
            .onChange(of: engine.hands) {
                checkScratchLogic()
            }
        }
    }
    
    private func checkScratchLogic() {
        guard !hasWon else { return }
        
        // 🚨 STRICT RULE: Game pauses if 2 hands are not visible!
        guard engine.hands.count == 2 else {
            previousPositions = [] // Reset the math so it doesn't glitch when hands reappear
            return
        }
        
        // 1. Get the X coordinates of both index fingers
        // We SORT them so [0] is always the left hand, and [1] is always the right hand.
        let currentPositions = engine.hands.map { $0.indexTip.x }.sorted()
        
        if previousPositions.count == 2 {
            // 2. Calculate "Delta" (How far did they move since the last millisecond?)
            let leftDelta = abs(currentPositions[0] - previousPositions[0])
            let rightDelta = abs(currentPositions[1] - previousPositions[1])
            
            // 3. Add movement to the Hype Meter!
            hypeLevel += (leftDelta + rightDelta)
            
            // 4. Check Win Condition
            if hypeLevel >= requiredHype {
                triggerWin()
            }
        }
        
        // Save current positions for the next frame's math
        previousPositions = currentPositions
    }
    
    private func triggerWin() {
        hasWon = true
        score += 50
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            onWin()
            // Sandbox Reset
            hypeLevel = 0.0
            previousPositions = []
            hasWon = false
        }
    }
}

// 🔧 Visual sub-view for the spinning records
struct DJDeckView: View {
    var hype: CGFloat
    var isActive: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black)
                .frame(width: 150, height: 150)
                .shadow(color: isActive ? .cyan : .clear, radius: 20)
            
            Circle()
                .stroke(Color.gray, lineWidth: 2)
                .frame(width: 100, height: 100)
            
            Circle()
                .fill(Color.red)
                .frame(width: 40, height: 40)
        }
        // The record physically spins faster the more you move your hands!
        .rotationEffect(.degrees(Double(hype * 360)))
        .opacity(isActive ? 1.0 : 0.5)
    }
}
