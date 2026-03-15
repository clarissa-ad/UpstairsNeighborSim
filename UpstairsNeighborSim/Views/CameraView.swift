import SwiftUI
import AVFoundation

struct CameraView: NSViewRepresentable {
    let session: AVCaptureSession
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        view.wantsLayer = true
        
        // Ensure we have a backing layer
        let rootLayer = CALayer()
        view.layer = rootLayer
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        
        // Mirror the root layer
        rootLayer.transform = CATransform3DMakeScale(-1, 1, 1)
        rootLayer.addSublayer(previewLayer)
        
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        // Force the preview layer to match exactly the bounds of the window
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        nsView.layer?.sublayers?.forEach { layer in
            if layer is AVCaptureVideoPreviewLayer {
                layer.frame = nsView.bounds
            }
        }
        CATransaction.commit()
    }
}
