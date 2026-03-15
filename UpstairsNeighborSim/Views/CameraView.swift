import SwiftUI
import AVFoundation

struct CameraView: NSViewRepresentable {
    let session: AVCaptureSession
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        view.wantsLayer = true
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        
        // We set a root layer to ensure the preview layer has a home
        let rootLayer = CALayer()
        view.layer = rootLayer
        rootLayer.addSublayer(previewLayer)
        
        // Mirror horizontally for a natural 'window' feel
        view.layer?.transform = CATransform3DMakeScale(-1, 1, 1)
        
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        // Essential: Keeps the camera feed filling the window
        if let previewLayer = nsView.layer?.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = nsView.bounds
        }
    }
}
