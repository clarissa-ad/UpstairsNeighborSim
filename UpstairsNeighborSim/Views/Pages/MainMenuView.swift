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
            Color.black.opacity(0.7).ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // 2. The Title Card
                VStack(spacing: 5) {
                    Text("TERRIBLE")
                        .font(.system(size: 50, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("NEIGHBOR")
                        .font(.system(size: 70, weight: .black, design: .rounded))
                        .foregroundColor(.red)
                        .shadow(color: .red.opacity(0.8), radius: isPulsing ? 25 : 10)
                }
                .scaleEffect(isPulsing ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isPulsing)
                
                Spacer()
                
                // 3. The Navigation Buttons
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
            .frame(maxWidth: 400) // Keeps it from getting too wide on an iPad
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
