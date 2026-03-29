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
        ZStack {
            Color.black.opacity(0.8).ignoresSafeArea()
            
            // 🌐 RESPONSIVE SPLIT LAYOUT
            HStack(spacing: 0) {
                
                // 👈 LEFT COLUMN: Title, Goal, Buttons
                VStack(alignment: .leading, spacing: 30) {
                    Spacer()
                    
                    // --- 1. INTEGRATED ANIMATED LOGO ---
                    ZStack(alignment: .topLeading) {
                        // The House acts as a background element for the text
                        Text("🏠")
                            .font(.system(size: 100))
                            .offset(x: -30, y: -45)
                            .rotationEffect(.degrees(-15))
                            .shadow(color: .red.opacity(0.6), radius: 15)
                        
                        VStack(alignment: .leading, spacing: -25) {
                            Text("NOISY")
                                .font(.system(size: 100, weight: .black, design: .rounded))
                                .foregroundColor(.red)
                                .shadow(color: .black, radius: 2) // Helps text stand out over the house
                            
                            Text("NEIGHBOR")
                                .font(.system(size: 85, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                    // The entire group animates together!
                    .rotationEffect(.degrees(isPulsing ? -2 : 1))
                    .scaleEffect(isPulsing ? 1.03 : 0.97)
                    .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: isPulsing)

                    // --- 2. UPGRADED GOAL CARD ---
                    HStack(alignment: .center, spacing: 15) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 35))
                            .foregroundColor(.yellow)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("MISSION OBJECTIVE")
                                .font(.system(.caption, design: .monospaced).bold())
                                .foregroundColor(.yellow)
                            
                            Text("MASTER THE CHALLENGES. RACK UP COMPLAINTS.")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Be the worst tenant on the floor.")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(15)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.yellow.opacity(0.6), lineWidth: 2)
                            .background(Color.yellow.opacity(0.05).cornerRadius(15))
                    )

                    // --- 3. ROUND SELECTOR HUD ---
                    VStack(alignment: .leading, spacing: 10) {
                        Text("GAME DURATION (ROUNDS)")
                            .font(.caption.bold())
                            .foregroundColor(.yellow)
                            .tracking(2)
                        
                        HStack(spacing: 20) {
                            Button(action: { if selectedRounds > 4 { selectedRounds -= 1 } }) {
                                Image(systemName: "minus.square.fill").font(.title)
                            }
                            Text("\(selectedRounds) ROUNDS")
                                .font(.system(size: 24, weight: .black, design: .monospaced))
                                .frame(width: 140, alignment: .leading)
                            
                            Button(action: { if selectedRounds < 10 { selectedRounds += 1 } }) {
                                Image(systemName: "plus.square.fill").font(.title)
                            }
                        }
                        .foregroundColor(.white)
                        
                        Text("+ 1 REDEMPTION ROUND (67)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.gray)
                    }

                    /// --- 4. NAVIGATION BUTTONS ---
                    VStack(alignment: .leading, spacing: 15) {
                        Button(action: { onPlaySolo(selectedRounds) }) {
                            MenuButtonView(title: "🧍‍♂️ SOLO CHAOS", color: .blue)
                        }
                        .buttonStyle(.plain) // ⬅️ MAGIC LINE: Removes the default translucent box
                        
                        Button(action: { onPlayVS(selectedRounds) }) {
                            MenuButtonView(title: "⚔️ VS MODE", color: .red)
                        }
                        .buttonStyle(.plain) // ⬅️ MAGIC LINE
                        
                        Button(action: { onDebug() }) {
                            MenuButtonView(title: "🛠️ PRACTICE MODE", color: .gray)
                        }
                        .buttonStyle(.plain) // ⬅️ MAGIC LINE
                    }
                    
                    Spacer()
                    Text("⚠️ Best played in full screen")
                        .font(.caption.bold())
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.bottom, 20)
                }
                .padding(.leading, 60) // Keeps the UI safely away from the left screen edge
                
                Spacer() // Pushes the UI to the Left, and Volume to the Right
                
                // 👉 RIGHT COLUMN: Audio Controls Pinned to Bottom Right
                VStack {
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 5) {
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
                                .frame(width: 120)
                                .onChange(of: volume) { newValue in
                                    isMuted = false
                                    AudioManager.shared.masterVolume = newValue
                                }
                            
                            Text("\(Int(volume * 100))%")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(.white)
                                .frame(width: 35, alignment: .trailing)
                        }
                    }
                    .padding(.trailing, 40)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear { isPulsing = true }
    }
}

// 🏗️ HELPER: Solid Fill Style (No Apple default background)
struct MenuButtonView: View {
    var title: String
    var color: Color
    
    var body: some View {
        Text(title)
            .font(.title2.bold())
            .foregroundColor(.white) // Keep text white
            .frame(width: 300, alignment: .center)
            .padding(.vertical, 15)
            .background(color) // ⬅️ Fills the button with the solid color
            .cornerRadius(15)
            .shadow(color: color.opacity(0.6), radius: 8, y: 5)
    }
}
