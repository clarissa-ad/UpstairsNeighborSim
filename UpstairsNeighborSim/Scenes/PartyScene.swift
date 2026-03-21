import SwiftUI

enum PartySide {
    case left
    case right
}

struct PartyScene: View {
    @ObservedObject var engine: TrackingEngine
    @Binding var score: Int
    var onComplete: (Bool) -> Void
    
    // 🔧 Game State
    @State private var currentSide: PartySide = .left
    @State private var hits: Int = 0
    @State private var hasWon: Bool = false
    @State private var bgColor: Color = .black
    
    // 📐 The Math
    let requiredHits: Int = 6
    let zoneWidthPercentage: CGFloat = 0.3
    let partyColors: [Color] = [.purple, .blue, .pink, .orange, .cyan]
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                bgColor
                    .ignoresSafeArea()
                    .animation(.interactiveSpring(), value: bgColor)
                
                VStack {
                    Text(hasWon ? "PARTY OVER!" : "HANDS UP!")
                        .font(.system(size: 60, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 5)
                    
                    Text("BEATS: \(hits) / \(requiredHits)")
                        .font(.title.bold())
                        .foregroundColor(.yellow)
                        .shadow(color: .black, radius: 2)
                    
                    Spacer()
                }
                .padding(40)
                
                if currentSide == .left && !hasWon {
                    HStack {
                        PartyTileView(text: "👋 WAVE!")
                            .frame(width: geo.size.width * zoneWidthPercentage)
                        Spacer()
                    }
                }
                
                if currentSide == .right && !hasWon {
                    HStack {
                        Spacer()
                        PartyTileView(text: "WAVE! 👋")
                            .frame(width: geo.size.width * zoneWidthPercentage)
                    }
                }
            }
            // 🔧 macOS 14 FIX: Removed the '_ in'
            .onChange(of: engine.hands) {
                checkWaveLogic(in: geo.size)
            }
        }
    }
    
    private func checkWaveLogic(in size: CGSize) {
        guard !hasWon else { return }
        
        for hand in engine.hands {
            let handX = (1 - hand.indexTip.x) * size.width
            
            if currentSide == .left {
                if handX < (size.width * zoneWidthPercentage) {
                    triggerHit(nextSide: .right)
                    break
                }
            } else {
                if handX > (size.width * (1.0 - zoneWidthPercentage)) {
                    triggerHit(nextSide: .left)
                    break
                }
            }
        }
    }
    
    private func triggerHit(nextSide: PartySide) {
        // sound
        AudioManager.shared.playSFX("whoosh")
        
        currentSide = nextSide
        hits += 1
        score += 20
        bgColor = partyColors.randomElement() ?? .purple
        
        if hits >= requiredHits {
            hasWon = true
            bgColor = .green
            score += 50
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                onComplete(true)
                hits = 0
                currentSide = .left
                bgColor = .black
                hasWon = false
            }
        }
    }
}

struct PartyTileView: View {
    var text: String
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.white.opacity(0.15))
                .border(Color.white, width: 3)
            
            Text(text)
                .font(.largeTitle.bold())
                .foregroundColor(.white)
        }
        .background(VisualEffectView(material: .hudWindow, blendingMode: .withinWindow))
    }
}

// 🔧 RESTORED MISSING CODE: The Frosted Glass Helper
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
