import SwiftUI

struct FurnitureScene: View {
    @ObservedObject var engine: TrackingEngine
    @Binding var score: Int
    var playerZone: PlayerZone = .solo
    var onComplete: (Bool) -> Void
    
    // 🔧 Game State
    @State private var chairLocalPosition: CGPoint = CGPoint(x: 0.5, y: 0.5)
    @State private var isGrabbed: Bool = false
    @State private var totalDistanceDragged: CGFloat = 0.0
    @State private var distanceToChair: CGFloat = 1.0
    
    // 📐 The Math Thresholds
    let pinchThreshold: CGFloat = 0.12
    let grabRadius: CGFloat = 0.25
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 🎨 1. THE AR CAMERA FILTER
                // Replaced the muddy brown with a vibrant, transparent neon filter!
                (isGrabbed ? Color.yellow : Color.orange)
                    .opacity(isGrabbed ? 0.3 : 0.15) // Low opacity so the camera shines through clearly
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.3), value: isGrabbed)
                
                // 2. HUD & Instruksi
                VStack {
                    Text("GESER KURSI!")
                        .font(.system(size: 50, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .orange, radius: 10)
                        
                    Text("DRAGGED: \(Int(totalDistanceDragged))m")
                        .font(.title.bold())
                        .foregroundColor(.yellow)
                        
                    Spacer()
                    
                    Text("Jepit jari (Pinch) ke kursi & seret!")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.bottom, 40)
                }
                .padding(40)
                .zIndex(2)
                
                // 3. Objek Kursi yang Bisa Diseret
                ZStack {
                    // 🧲 Visual Feedback
                    Circle()
                        .fill(isGrabbed ? Color.yellow.opacity(0.5) : (distanceToChair < grabRadius ? Color.white.opacity(0.3) : Color.clear))
                        .frame(width: 120, height: 120)
                        .scaleEffect(isGrabbed ? 1.2 : 1.0)
                        .animation(.spring().repeatForever(autoreverses: true), value: isGrabbed)
                    
                    Text("🪑")
                        .font(.system(size: 80))
                }
                .position(
                    x: chairLocalPosition.x * geo.size.width,
                    y: chairLocalPosition.y * geo.size.height
                )
                .animation(.interactiveSpring(response: 0.1, dampingFraction: 0.8), value: chairLocalPosition)
            }
            .onChange(of: engine.hands) {
                checkPinchAndDrag(in: geo.size)
            }
            .onDisappear {
                AudioManager.shared.forceStopScrape()
            }
        }
    }
    
    private func checkPinchAndDrag(in size: CGSize) {
        let validHands = engine.hands.filter {
            CoordinateMapper.belongsToZone(rawX: $0.indexTip.x, zone: playerZone)
        }
        
        var foundGrabThisFrame = false
        var closestHandDistance: CGFloat = 1.0
        
        for hand in validHands {
            let rawIndex = hand.indexTip
            let rawThumb = hand.thumbTip
            
            let pinchDistance = hypot(rawIndex.x - rawThumb.x, rawIndex.y - rawThumb.y)
            let isPinching = pinchDistance < pinchThreshold
            
            let localHandPoint = CoordinateMapper.localPoint(rawPoint: rawIndex, zone: playerZone, screenSize: size)
            let localHandX = localHandPoint.x / size.width
            let localHandY = 1.0 - (localHandPoint.y / size.height)
            
            let currentDistance = hypot(localHandX - chairLocalPosition.x, localHandY - chairLocalPosition.y)
            
            if currentDistance < closestHandDistance {
                closestHandDistance = currentDistance
            }
            
            if isPinching {
                if isGrabbed || currentDistance < grabRadius {
                    // 🔥 BERHASIL GRAB!
                    foundGrabThisFrame = true
                    
                    let dragDelta = hypot(localHandX - chairLocalPosition.x, localHandY - chairLocalPosition.y)
                    
                    if dragDelta > 0.005 {
                        AudioManager.shared.playScrapeOnce()
                        
                        totalDistanceDragged += (dragDelta * 100)
                        
                        if totalDistanceDragged.truncatingRemainder(dividingBy: 10) < dragDelta * 100 {
                            score += 5
                        }
                    }
                    
                    // Pindahkan kursi
                    chairLocalPosition = CGPoint(x: localHandX, y: localHandY)
                    break
                }
            }
        }
        
        isGrabbed = foundGrabThisFrame
        distanceToChair = closestHandDistance
    }
}
