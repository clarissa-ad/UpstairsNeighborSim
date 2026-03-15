import SwiftUI

struct ContentView: View {
    @StateObject private var engine = TrackingEngine()
    @StateObject private var blobGame = BlobScene() // Our new interaction module
    
    let handColors: [Color] = [.green, .cyan]
    
    var body: some View {
        GeometryReader { geo in // We use GeometryReader to get the screen size for physics
            ZStack {
                // Layer 1: Camera (Still there in case it wakes up)
                CameraView(session: engine.session)
                    .opacity(0.1)
                    .ignoresSafeArea()
                
                // Layer 2: The Interaction (The Blob)
                Circle()
                    .fill(blobGame.isBeingPushed ? Color.orange : Color.blue)
                    .frame(width: 100, height: 100)
                    .position(blobGame.position)
                    .shadow(radius: blobGame.isBeingPushed ? 20 : 5)
                    .animation(.spring(), value: blobGame.position)
                
                // Layer 3: The Hand Skeleton
                Canvas { context, size in
                    for (index, points) in engine.handGroups.enumerated() {
                        let color = handColors[index % handColors.count]
                        for point in points {
                            let x = point.x * size.width
                            let y = (1 - point.y) * size.height
                            context.fill(Path(ellipseIn: CGRect(x: x-5, y: y-5, width: 10, height: 10)), with: .color(color))
                        }
                    }
                }
            }
            // This links the Engine to the Game every time the hands move
            .onChange(of: engine.handGroups) {
                blobGame.update(with: engine.handGroups, in: geo.size)
            }
        }
        .frame(minWidth: 800, minHeight: 600)
        .onAppear { engine.start() }
    }
}
