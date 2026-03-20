import SwiftUI
import Combine

struct TargetDot: Identifiable {
    let id = UUID()
    var position: CGPoint
    var isExploding: Bool = false
}

class ThudScene: ObservableObject {
    @Published var dots: [TargetDot] = []
    @Published var score: Int = 0 // <--- 1. NEW SCORE TRACKER
    
    init() {
        for _ in 0..<3 { spawnDot(in: CGSize(width: 800, height: 600)) }
    }
    
    func spawnDot(in size: CGSize) {
        let w = max(size.width, 800)
        let h = max(size.height, 600)
        let randomX = CGFloat.random(in: 100...(w - 100))
        let randomY = CGFloat.random(in: 100...(h - 100))
        dots.append(TargetDot(position: CGPoint(x: randomX, y: randomY)))
    }
    
    func update(with handGroups: [[CGPoint]], in size: CGSize) {
        for group in handGroups {
            guard !group.isEmpty else { continue }
            
            let avgX = group.map { $0.x }.reduce(0, +) / CGFloat(group.count)
            let avgY = group.map { $0.y }.reduce(0, +) / CGFloat(group.count)
            
            let handCenterX = (1 - avgX) * size.width
            let handCenterY = (1 - avgY) * size.height
            
            for i in 0..<dots.count {
                if !dots[i].isExploding {
                    let dist = sqrt(pow(handCenterX - dots[i].position.x, 2) + pow(handCenterY - dots[i].position.y, 2))
                    if dist < 60 {
                        triggerImpact(at: i, in: size)
                    }
                }
            }
        }
    }
    
    private func triggerImpact(at index: Int, in size: CGSize) {
        dots[index].isExploding = true
        let idToReplace = dots[index].id
        
        // <--- 2. INCREMENT THE SCORE WHEN HIT
        score += 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            if let realIndex = self.dots.firstIndex(where: { $0.id == idToReplace }) {
                self.dots.remove(at: realIndex)
                self.spawnDot(in: size)
            }
        }
    }
}
