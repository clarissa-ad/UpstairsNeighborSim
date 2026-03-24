import SwiftUI

struct FurnitureScene: View {
    @ObservedObject var engine: TrackingEngine
    @Binding var score: Int
    var playerZone: PlayerZone = .solo
    var onComplete: (Bool) -> Void
    
    // 🔧 Game State
    @State private var chairLocalPosition: CGPoint = CGPoint(x: 0.5, y: 0.5) // Posisi tengah layar (dalam persentase)
    @State private var isGrabbed: Bool = false
    @State private var totalDistanceDragged: CGFloat = 0.0
    
    // 📐 The Math Thresholds
    let pinchThreshold: CGFloat = 0.12 // Jarak maksimal jempol & telunjuk untuk dianggap "mencubit"
    let grabRadius: CGFloat = 0.25     // Jarak maksimal tangan ke kursi untuk bisa mengambilnya
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 1. Latar Belakang Kayu (Warna Coklat)
                Color.brown.opacity(0.3).ignoresSafeArea()
                
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
                    // Efek getar saat ditarik
                    Circle()
                        .fill(isGrabbed ? Color.yellow.opacity(0.5) : Color.clear)
                        .frame(width: 120, height: 120)
                        .scaleEffect(isGrabbed ? 1.2 : 1.0)
                        .animation(.spring().repeatForever(autoreverses: true), value: isGrabbed)
                    
                    Text("🪑")
                        .font(.system(size: 80))
                }
                // Mapping posisi kursi ke ukuran layar lokal
                .position(
                    x: chairLocalPosition.x * geo.size.width,
                    y: chairLocalPosition.y * geo.size.height
                )
                .animation(.interactiveSpring(response: 0.1, dampingFraction: 0.8), value: chairLocalPosition)
            }
            .onChange(of: engine.hands) {
                checkPinchAndDrag(in: geo.size)
            }
        }
    }
    
    private func checkPinchAndDrag(in size: CGSize) {
        // 🛑 1. MULTIPLAYER FILTER
        let validHands = engine.hands.filter {
            CoordinateMapper.belongsToZone(rawX: $0.indexTip.x, zone: playerZone)
        }
        
        var foundGrabThisFrame = false
        
        for hand in validHands {
            // Asumsi: TrackingEngine kamu punya properti thumbTip dan indexTip
            // (Jika engine kamu tidak punya thumbTip, kasih tahu saya, kita bisa pakai titik lain!)
            let rawIndex = hand.indexTip
            let rawThumb = hand.thumbTip
            
            // 📐 SPATIAL MATH 1: Apakah jari sedang mencubit? (Jarak Jempol ke Telunjuk)
            let pinchDistance = hypot(rawIndex.x - rawThumb.x, rawIndex.y - rawThumb.y)
            let isPinching = pinchDistance < pinchThreshold
            
            // 🎯 UNIVERSAL LENS: Konversi posisi telunjuk ke UI lokal
            let localHandPoint = CoordinateMapper.localPoint(rawPoint: rawIndex, zone: playerZone, screenSize: size)
            
            // Konversi kembali ke persentase (0.0 - 1.0) agar matematisnya seragam
            let localHandX = localHandPoint.x / size.width
            let localHandY = 1.0 - localHandPoint.y / size.height
            
            // 📐 SPATIAL MATH 2: Apakah cubitan berada di dekat kursi?
            let distanceToChair = hypot(localHandX - chairLocalPosition.x, localHandY - chairLocalPosition.y)
            
            if isPinching {
                if isGrabbed || distanceToChair < grabRadius {
                    // 🔥 BERHASIL GRAB! Kursi mengikuti tangan
                    foundGrabThisFrame = true
                    
                    if !isGrabbed {
                        AudioManager.shared.playSFX("grab") // Bunyi "Plop!"
                    }
                    
                    // Hitung seberapa jauh ditarik frame ini untuk nambah skor
                    let dragDelta = hypot(localHandX - chairLocalPosition.x, localHandY - chairLocalPosition.y)
                    totalDistanceDragged += (dragDelta * 100) // Dikali 100 agar angkanya besar
                    
                    // Update skor secara real-time berdasarkan jarak tarikan!
                    if totalDistanceDragged.truncatingRemainder(dividingBy: 10) < dragDelta * 100 {
                        score += 5
                    }
                    
                    // Pindahkan kursi
                    chairLocalPosition = CGPoint(x: localHandX, y: localHandY)
                    break // Fokus ke tangan pertama yang berhasil grab
                }
            }
        }
        
        // Update state jika tangan dilepas (un-pinch)
        isGrabbed = foundGrabThisFrame
    }
}
