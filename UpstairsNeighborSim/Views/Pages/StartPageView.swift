import SwiftUI

struct StartPageView: View {
    @ObservedObject var engine: TrackingEngine
    var onStart: () -> Void
    var onDebug: () -> Void // 🔧 NEW callback
    
    var body: some View {
        ZStack {
            // Secret Debug Menu Top Right
            VStack {
                HStack {
                    Spacer()
                    Menu {
                        Button("🔧 Open Scene Sandbox", action: onDebug)
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(10)
                    }
                    .menuStyle(.borderlessButton)
                }
                .padding(30)
                Spacer()
            }
            
            // Main Titles
            VStack {
                Text("TETANGGA BERISIK")
                    .font(.system(size: 60, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
                    .shadow(radius: 10)
                
                Text("The Upstairs Neighbor Simulator")
                    .font(.title2)
                    .foregroundColor(.yellow)
                    .padding(.bottom, 50)
                
                Button(action: onStart) {
                    Text("HIGH-FIVE TO START")
                        .font(.title.bold())
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
            }
        }
    }
}
