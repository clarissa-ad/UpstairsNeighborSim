import SwiftUI

struct StartPageView: View {
    @ObservedObject var engine: TrackingEngine
    var onStart: () -> Void
    var onDebug: () -> Void
    
    var body: some View {
        ZStack {
            // Practice Gym Menu (Top Right)
            VStack {
                HStack {
                    Spacer()
                    Button(action: onDebug) {
                        HStack {
                            Text("🏋️")
                            Text("Practice Gym")
                                .font(.headline.bold())
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue.opacity(0.8))
                        .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
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
                .buttonStyle(.plain) // Ensures clickability in macOS
            }
        }
    }
}
