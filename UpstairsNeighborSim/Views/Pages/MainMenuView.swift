import SwiftUI

struct MainMenuView: View {
    // 🧠 It accepts the master engine just in case you want to use it for menu interactions later!
    @ObservedObject var engine: TrackingEngine
    
    // 🔀 The Routing Levers
    var onPlaySolo: () -> Void
    var onPlayVS: () -> Void
    var onDebug: () -> Void
    
    // 🎬 Visual Polish
    @State private var isPulsing = false
    
    var body: some View {
        ZStack {
            // 1. Darken the live camera feed running in the background
            Color.black.opacity(0.8).ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                // ==========================================
                // 2. THE TITLE CARD
                // ==========================================
                VStack(spacing: 15) { // Spasi antara grup judul dan subtitle
                    
                    // 🅰️ THE OVERLAPPING TITLE
                    VStack(spacing: -30) { // ⬅️ NEGATIVE SPACING: Rahasia utama agar benar-benar menumpuk!
                        Text("🏠 UPSTAIRS")
                            .font(.system(size: 55, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .zIndex(0)
                        
                        Text("NEIGHBOR")
                            .font(.system(size: 55, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .zIndex(0)
                        
                        Text("SIM!")
                            .font(.system(size: 85, weight: .black, design: .rounded)) // Size dibesarkan sedikit
                            .foregroundColor(.red)
                            .shadow(color: .red.opacity(0.8), radius: isPulsing ? 25 : 10)
                            .rotationEffect(.degrees(-8)) // ⬅️ SEDIKIT MIRING (Angled!)
                            .zIndex(1) // Memastikan "SIM!" dirender di atas teks putih
                    }
                    
                    // 📝 THE SUBTITLE HOOK
                    Text("Rack up noise complaints. Be the worst neighbor.")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                // Efek denyut tetap dipertahankan untuk seluruh grup ini
                .scaleEffect(isPulsing ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isPulsing)
                
                Spacer()
                
                // ==========================================
                // 3. THE NAVIGATION BUTTONS
                // ==========================================
                VStack(spacing: 25) {
                    Button(action: onPlaySolo) {
                        MenuButtonView(title: "🧍‍♂️ SOLO CHAOS", color: .blue)
                    }
                    
                    Button(action: onPlayVS) {
                        MenuButtonView(title: "⚔️ VS MODE", color: .red)
                    }
                    
                    Button(action: onDebug) {
                        MenuButtonView(title: "🛠️ PRACTICE GYM", color: .gray)
                    }
                }
                .padding(.horizontal, 50)
                
                Spacer()
                
                // ==========================================
                // 4. THE FOOTER NOTE
                // ==========================================
                Text("⚠️ Best played in full screen")
                    .font(.caption.bold())
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.bottom, 20)
            }
        }
        .onAppear {
            isPulsing = true
        }
    }
}

// 🏗️ HELPER: A reusable button style to keep the code clean
struct MenuButtonView: View {
    var title: String
    var color: Color
    
    var body: some View {
        Text(title)
            .font(.title.bold())
            .foregroundColor(.white)
            .frame(maxWidth: 400) // Keeps it from getting too wide on an iPad/Mac
            .padding(.vertical, 20)
            .background(color)
            .cornerRadius(20)
            .shadow(color: color.opacity(0.5), radius: 10, y: 5)
    }
}

// 🔧 PREVIEW
struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView(
            engine: TrackingEngine(),
            onPlaySolo: {},
            onPlayVS: {},
            onDebug: {}
        )
    }
}
