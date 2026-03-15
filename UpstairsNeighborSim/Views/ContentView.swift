import SwiftUI

struct ContentView: View {
    @StateObject private var engine = TrackingEngine()
    
    // Hand 1 = Green, Hand 2 = Cyan
    let handColors: [Color] = [.green, .cyan]
    
    var body: some View {
        ZStack {
            // LAYER 1: The Camera (The "Neighbor")
            // I set this to 0.3 opacity so you can confirm it's working
            CameraView(session: engine.session)
                .opacity(0.3)
                .background(Color.blue.opacity(0.1)) // Blue hint if camera fails
                .ignoresSafeArea()
            
            // LAYER 2: Diagnostic HUD
            VStack {
                HStack {
                    Text("NEIGHBOR HANDS: \(engine.handCount)")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .padding(10)
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    Spacer()
                }
                Spacer()
            }
            .padding()

            // LAYER 3: The Skeleton Overlay
            Canvas { context, size in
                for (index, points) in engine.handGroups.enumerated() {
                    let color = handColors[index % handColors.count]
                    
                    for point in points {
                        // Math for mirrored X:
                        // Vision (0,0 bottom-left) to SwiftUI (0,0 top-left)
                        let x = point.x * size.width
                        let y = (1 - point.y) * size.height
                        
                        let dot = Path(ellipseIn: CGRect(x: x-5, y: y-5, width: 10, height: 10))
                        context.fill(dot, with: .color(color))
                        context.stroke(dot, with: .color(.white), lineWidth: 1)
                    }
                }
            }
            
            // LAYER 4: The Window Frame
            Rectangle()
                .stroke(Color.white.opacity(0.15), lineWidth: 40)
                .ignoresSafeArea()
        }
        .frame(minWidth: 800, minHeight: 600)
        .onAppear {
            engine.start()
        }
    }
}
