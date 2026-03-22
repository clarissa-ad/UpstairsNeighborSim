import SwiftUI

enum AppState {
    case intro
    case playingSolo
    case playingVS
    case debug
}

struct ContentView: View {
    // ONE Engine to rule them all!
    @StateObject private var engine = TrackingEngine()
    @State private var currentState: AppState = .intro
    
    var body: some View {
        GeometryReader { outerGeo in
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                HStack(spacing: 0) {
                    Spacer(minLength: 0)
                    
                    // 🔒 THE VAULT: Everything is permanently locked to a 16:9 ratio.
                    ZStack {
                        // LAYER 1: The Camera
                        CameraView(session: engine.session)
                        
                        // LAYER 2: The Page Router
                        Group {
                            switch currentState {
                            case .intro:
                                StartPageView(engine: engine, onStart: {
                                    currentState = .playingSolo // Default to Solo for now
                                }, onDebug: {
                                    currentState = .debug
                                })
                                
                            case .playingSolo:
                                GamePageView(engine: engine, isMultiplayer: false) {
                                    currentState = .intro // Goes back to menu after Results!
                                }
                                
                            case .playingVS:
                                GamePageView(engine: engine, isMultiplayer: true) {
                                    currentState = .intro // Goes back to menu after Results!
                                }
                                
                            case .debug:
                                DebugTrackerView(engine: engine) {
                                    currentState = .intro
                                }
                            }
                        }
                        
                        // LAYER 3: The Precise AR Skeleton
                        Canvas { context, size in
                            for hand in engine.hands {
                                for point in hand.allPoints {
                                    // Mirror the X coordinate to match the camera
                                    let x = (1 - point.x) * size.width
                                    let y = (1 - point.y) * size.height
                                    let dot = Path(ellipseIn: CGRect(x: x-4, y: y-4, width: 8, height: 8))
                                    context.fill(dot, with: .color(.green))
                                }
                            }
                        }
                        .drawingGroup()
                        .allowsHitTesting(false) // So it doesn't block the buttons!
                    }
                    .aspectRatio(16/9, contentMode: .fit)
                    .clipped()
                    
                    Spacer(minLength: 0)
                }
                Spacer(minLength: 0)
            }
            .background(Color.black)
        }
        .frame(minWidth: 800, minHeight: 600)
        .onAppear {
            engine.start()
        }
    }
}
