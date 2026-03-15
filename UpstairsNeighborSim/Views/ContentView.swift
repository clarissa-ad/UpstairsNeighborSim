import SwiftUI

struct ContentView: View {
    @StateObject private var engine = TrackingEngine()
    @StateObject private var blobGame = BlobScene()
    
    let handColors: [Color] = [.green, .cyan]
    
    var body: some View {
        GeometryReader { geo in
            // By wrapping the ZStack in a frame that centers it,
            // the 16:9 box will float perfectly in the middle of any window size.
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    
                    ZStack {
                        // LAYER 1: The Camera (Mirrored natively)
                        CameraView(session: engine.session)
                            .opacity(1.0)
                        
                        // LAYER 2: The Blob
                        Circle()
                            .fill(blobGame.isBeingPushed ? Color.orange : Color.blue)
                            .frame(width: 100, height: 100)
                            .position(blobGame.position)
                            .shadow(radius: blobGame.isBeingPushed ? 20 : 5)
                            .animation(.spring(), value: blobGame.position)
                        
                        // LAYER 3: The Exact Skeleton
                        Canvas { context, size in
                            for (index, points) in engine.handGroups.enumerated() {
                                let color = handColors[index % handColors.count]
                                for point in points {
                                    // MIRROR FIX: 1 - point.x aligns the math with the mirrored video
                                    let x = (1 - point.x) * size.width
                                    let y = (1 - point.y) * size.height
                                    
                                    let dot = Path(ellipseIn: CGRect(x: x-4, y: y-4, width: 8, height: 8))
                                    context.fill(dot, with: .color(color))
                                }
                            }
                        }
                    }
                    // THE DRIFT FIX: This locks the coordinate space to the standard Mac camera ratio
                    .aspectRatio(16/9, contentMode: .fit)
                    // We pass the EXACT size of this 16:9 box to the physics engine
                    .background(
                        GeometryReader { innerGeo in
                            Color.clear.onChange(of: engine.handGroups) {
                                blobGame.update(with: engine.handGroups, in: innerGeo.size)
                            }
                        }
                    )
                    
                    Spacer()
                }
                Spacer()
            }
            .background(Color.black) // Fills the empty space if you resize the window weirdly
        }
        .frame(minWidth: 800, minHeight: 600)
        .onAppear { engine.start() }
    }
}
