import SwiftUI

struct MainMenuView: View {
    @ObservedObject var engine: TrackingEngine
    var onPlaySolo: (Int) -> Void
    var onPlayVS: (Int) -> Void
    var onDebug: () -> Void
    
    @State private var isPulsing = false
    @State private var selectedRounds: Int = 5
    
    // 🔊 Volume State
    @State private var volume: Float = 0.5
    @State private var isMuted: Bool = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.black.opacity(0.8).ignoresSafeArea()
            
            // --- MAIN UI (CENTERED) ---
            VStack(spacing: 25) {
                Spacer()
                
                // --- TITLE CARD ---
                VStack(spacing: 15) {
                    VStack(spacing: -30) {
                        Text("🏠 UPSTAIRS").font(.system(size: 55, weight: .heavy, design: .rounded)).foregroundColor(.white).zIndex(0)
                        Text("NEIGHBOR").font(.system(size: 55, weight: .heavy, design: .rounded)).foregroundColor(.white).zIndex(0)
                        Text("SIM!").font(.system(size: 85, weight: .black, design: .rounded)).foregroundColor(.red).shadow(color: .red.opacity(0.8), radius: isPulsing ? 25 : 10).rotationEffect(.degrees(-8)).zIndex(1)
                    }
                    Text("Rack up noise complaints. Be the worst neighbor.").font(.headline).foregroundColor(.gray)
                }
                .scaleEffect(isPulsing ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isPulsing)
                
                Spacer()

                // 🛠️ ROUND SELECTOR HUD
                VStack(spacing: 10) {
                    Text("SEQUENCE LENGTH").font(.caption.bold()).foregroundColor(.yellow).tracking(2)
                    HStack(spacing: 20) {
                        Button(action: { if selectedRounds > 4 { selectedRounds -= 1 } }) {
                            Image(systemName: "minus.square.fill").font(.title)
                        }
                        Text("\(selectedRounds) ROUNDS").font(.system(size: 24, weight: .black, design: .monospaced)).frame(width: 140)
                        Button(action: { if selectedRounds < 10 { selectedRounds += 1 } }) {
                            Image(systemName: "plus.square.fill").font(.title)
                        }
                    }
                    .foregroundColor(.white)
                    Text("+ 67 REDEMPTION ROUND").font(.system(size: 10, weight: .bold)).foregroundColor(.gray)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 15).fill(Color.white.opacity(0.1)))

                // --- NAVIGATION BUTTONS ---
                VStack(spacing: 20) {
                    Button(action: { onPlaySolo(selectedRounds) }) {
                        MenuButtonView(title: "🧍‍♂️ SOLO CHAOS", color: .blue)
                    }
                    Button(action: { onPlayVS(selectedRounds) }) {
                        MenuButtonView(title: "⚔️ VS MODE", color: .red)
                    }
                    Button(action: { onDebug() }) {
                        MenuButtonView(title: "🛠️ PRACTICE GYM", color: .gray)
                    }
                }
                .padding(.horizontal, 50)
                
                Spacer()
                
                Text("⚠️ Best played in full screen").font(.caption.bold()).foregroundColor(.white.opacity(0.5)).padding(.bottom, 20)
            }
            
            // 🔊 SMALL VOLUME CORNER (Pinned to Bottom Left independently)
            VStack(alignment: .leading, spacing: 5) {
                Text("ADJUST BACKGROUND MUSIC")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.6))
                
                HStack(spacing: 10) {
                    Button(action: {
                        isMuted.toggle()
                        AudioManager.shared.masterVolume = isMuted ? 0 : volume
                    }) {
                        Image(systemName: isMuted || volume == 0 ? "speaker.slash.fill" : "speaker.wave.2.fill")
                            .font(.system(size: 14))
                            .foregroundColor(isMuted ? .red : .white)
                    }

                    Slider(value: $volume, in: 0...1)
                        .tint(.red)
                        .frame(width: 100)
                        .onChange(of: volume) { newValue in
                            isMuted = false
                            AudioManager.shared.masterVolume = newValue
                        }
                    
                    Text("\(Int(volume * 100))%")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.white)
                        .frame(width: 35)
                }
            }
            .padding(.leading, 30) // Left padding
            .padding(.bottom, 30)
            // This frame expands to fill the ZStack and pins the content to the bottom-left
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        }
        .onAppear { isPulsing = true }
    }
    
    // 🏗️ HELPER: This defines the button style and fixes the "Cannot find in scope" errors
    struct MenuButtonView: View {
        var title: String
        var color: Color
        
        var body: some View {
            Text(title)
                .font(.title.bold())
                .foregroundColor(.white)
                .frame(maxWidth: 400)
                .padding(.vertical, 20)
                .background(color)
                .cornerRadius(20)
                .shadow(color: color.opacity(0.5), radius: 10, y: 5)
        }
    }
}
