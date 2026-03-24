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
    @State private var selectedRounds: Int = 5
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
                                MainMenuView(
                                    engine: engine,
                                    onPlaySolo: { rounds in // ⬅️ Catch the argument here
                                        self.selectedRounds = rounds
                                        self.currentState = .playingSolo
                                    },
                                    onPlayVS: { rounds in // ⬅️ Catch the argument here
                                        self.selectedRounds = rounds
                                        self.currentState = .playingVS
                                    },
                                    onDebug: {
                                        self.currentState = .debug
                                    }
                                )
                                
                            case .playingSolo:
                                GamePageView(
                                    engine: engine,
                                    isMultiplayer: false,
                                    rounds: selectedRounds, // ⬅️ Pass the caught value
                                    onReturnToMenu: { self.currentState = .intro }
                                )

                            case .playingVS:
                                GamePageView(
                                    engine: engine,
                                    isMultiplayer: true,
                                    rounds: selectedRounds, // ⬅️ Pass the caught value
                                    onReturnToMenu: { self.currentState = .intro }
                                )
                                
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
