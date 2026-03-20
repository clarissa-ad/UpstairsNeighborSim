import SwiftUI
import Combine

class BlobScene: ObservableObject {
    @Published var position: CGPoint = CGPoint(x: 400, y: 300)
    @Published var isBeingPushed: Bool = false
    private let blobSize: CGFloat = 100
    
    func update(with handPoints: [[CGPoint]], in size: CGSize) {
        var pushed = false
        for group in handPoints {
            for point in group {
                // MIRROR FIX: We subtract point.x from 1 to flip it horizontally
                let fingerX = (1 - point.x) * size.width
                let fingerY = (1 - point.y) * size.height
                
                let dist = sqrt(pow(fingerX - position.x, 2) + pow(fingerY - position.y, 2))
                
                if dist < (blobSize / 2) {
                    pushed = true
                    let dx = position.x - fingerX
                    let dy = position.y - fingerY
                    position.x += dx * 0.1
                    position.y += dy * 0.1
                }
            }
        }
        position.x = min(max(position.x, blobSize), size.width - blobSize)
        position.y = min(max(position.y, blobSize), size.height - blobSize)
        self.isBeingPushed = pushed
    }
}
