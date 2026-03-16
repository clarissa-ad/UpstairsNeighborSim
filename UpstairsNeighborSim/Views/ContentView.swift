import SwiftUI

// test

// 1. THE SCALABLE ROSTER
// This is your "Registry". Add one line here, and the menu updates automatically.
enum Activity: String, CaseIterable {
    case blob = "🔴 The Blob"
    case thud = "💥 The Thud" // ADDED: Our new impact game!
    case empty = "📷 Camera Only"
    // Example for tomorrow:
    // case rubberDuck = "🦆 Duck Ambassador"
}

struct ContentView: View {
    @StateObject private var engine = TrackingEngine()
    @StateObject private var blobGame = BlobScene()
    @StateObject private var thudGame = ThudScene() // ADDED: The thud game engine
    
    // 2. STATE: Keeps track of which game is currently playing
    @State private var currentActivity: Activity = .blob
    
    let handColors: [Color] = [.green, .cyan]
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    
                    ZStack {
                        // LAYER 1: The Camera
                        CameraView(session: engine.session)
                            .opacity(1.0)
                        
                        // LAYER 2: THE MODULAR ACTIVITY SWITCHER
                        Group {
                            switch currentActivity {
                            case .blob:
                                Circle()
                                    .fill(blobGame.isBeingPushed ? Color.orange : Color.blue)
                                    .frame(width: 100, height: 100)
                                    .position(blobGame.position)
                                    .shadow(radius: blobGame.isBeingPushed ? 20 : 5)
                                    .animation(.spring(), value: blobGame.position)
                                    
                            case .thud:
                                // 1. Draw the Target Dots
                                ForEach(thudGame.dots) { dot in
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 50, height: 50)
                                        .scaleEffect(dot.isExploding ? 4.0 : 1.0)
                                        .opacity(dot.isExploding ? 0.0 : 0.8)
                                        .position(dot.position)
                                        .animation(.easeOut(duration: 0.4), value: dot.isExploding)
                                }
                                
                                // 2. NEW: Draw the Score UI
                                VStack {
                                    HStack {
                                        Text("THUDS: \(thudGame.score)")
                                            .font(.system(.title2, design: .monospaced).bold())
                                            .foregroundColor(.white)
                                            .padding()
                                            .background(VisualEffectView(material: .hudWindow, blendingMode: .withinWindow).cornerRadius(10))
                                            .shadow(radius: 5)
                                            .padding() // Gives it some breathing room from the edges
                                        Spacer()
                                    }
                                    Spacer()
                                }
                                
                            case .empty:
                                // Just the camera and skeleton, nothing to interact with
                                EmptyView()
                            }
                        }
                        
                        // LAYER 3: The Exact Skeleton
                        Canvas { context, size in
                            for (index, points) in engine.handGroups.enumerated() {
                                let color = handColors[index % handColors.count]
                                for point in points {
                                    let x = (1 - point.x) * size.width
                                    let y = (1 - point.y) * size.height
                                    let dot = Path(ellipseIn: CGRect(x: x-4, y: y-4, width: 8, height: 8))
                                    context.fill(dot, with: .color(color))
                                }
                            }
                        }
                        
                        // LAYER 4: The Floating Burger Menu
                        VStack {
                            Menu {
                                // Automatically loops through all 'Activity' cases
                                ForEach(Activity.allCases, id: \.self) { activity in
                                    Button(activity.rawValue) {
                                        currentActivity = activity
                                    }
                                }
                            } label: {
                                Image(systemName: "line.3.horizontal")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(VisualEffectView(material: .hudWindow, blendingMode: .withinWindow).cornerRadius(10))
                                    .shadow(radius: 5)
                            }
                            .menuStyle(.borderlessButton) // Removes the default Mac button styling
                            .frame(width: 60)
                            
                            Spacer() // Pushes the menu to the top
                        }
                        .padding(.top, 20)
                        
                    }
                    .aspectRatio(16/9, contentMode: .fit)
                    .background(
                        GeometryReader { innerGeo in
                            Color.clear.onChange(of: engine.handGroups) {
                                // We keep updating the game engines in the background
                                blobGame.update(with: engine.handGroups, in: innerGeo.size)
                                thudGame.update(with: engine.handGroups, in: innerGeo.size) // ADDED: Send hand data to the Thud engine
                            }
                        }
                    )
                    Spacer()
                }
                Spacer()
            }
            .background(Color.black)
        }
        .frame(minWidth: 800, minHeight: 600)
        .onAppear { engine.start() }
    }
}

// Helper for the nice frosted glass effect behind the burger menu
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
