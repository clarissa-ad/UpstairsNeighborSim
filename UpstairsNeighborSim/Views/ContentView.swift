import SwiftUI

enum GameState {
    case intro
    case playing
    case results
    case debug
}

struct ContentView: View {
    @StateObject private var engine = TrackingEngine()
    @State private var currentState: GameState = .intro
    @State private var totalScore: Int = 0
    
    var body: some View {
        GeometryReader { outerGeo in
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                HStack(spacing: 0) {
                    Spacer(minLength: 0)
                    
                    // 🔒 THE VAULT: Everything inside this ZStack is permanently locked to a 16:9 ratio.
                    // This guarantees the camera pixels and the AI math pixels are a 1:1 match.
                    ZStack {
                        // LAYER 1: The Camera
                        CameraView(session: engine.session)
                        
                        // LAYER 2: The Page Router
                        Group {
                            switch currentState {
                            case .intro:
                                StartPageView(engine: engine, onStart: {
                                    currentState = .playing
                                    totalScore = 0
                                }, onDebug: {
                                    currentState = .debug
                                })
                                
                            case .playing:
                                GamePageView(engine: engine, score: $totalScore) {
                                    currentState = .results
                                }
                                
                            case .results:
                                ResultsPageView(score: totalScore) {
                                    currentState = .intro
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
                                    let x = (1 - point.x) * size.width
                                    let y = (1 - point.y) * size.height
                                    let dot = Path(ellipseIn: CGRect(x: x-4, y: y-4, width: 8, height: 8))
                                    context.fill(dot, with: .color(.green))
                                }
                            }
                        }
                        .drawingGroup()
                        .allowsHitTesting(false)
                    }
                    .aspectRatio(16/9, contentMode: .fit) // THE MAGIC FIX
                    .clipped() // Prevents anything from spilling outside the 16:9 box
                    
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
