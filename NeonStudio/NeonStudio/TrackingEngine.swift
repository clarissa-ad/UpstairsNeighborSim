import SwiftUI
import AVFoundation
import Vision
import Combine
import CoreImage // ⬅️ NEW: Needed for image filters!

class TrackingEngine: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    // ⬅️ NEW: Instead of points, we broadcast a ready-to-draw Image
    @Published var outlineImage: CGImage?
    
    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let requestHandler = VNSequenceRequestHandler()
    
    // Core Image context used to process the outline quickly
    private let ciContext = CIContext()
    
    func start() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.setupCamera()
        }
    }
    
    private func setupCamera() {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .high
        
        guard let camera = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            print("❌ Could not find camera.")
            return
        }
        
        if captureSession.canAddInput(input) { captureSession.addInput(input) }
        
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        videoOutput.alwaysDiscardsLateVideoFrames = true
        
        if captureSession.canAddOutput(videoOutput) { captureSession.addOutput(videoOutput) }
        
        captureSession.commitConfiguration()
        captureSession.startRunning()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        // 🚨 THE MAGIC: Ask Vision for a Background Segmentation Mask
        let request = VNGeneratePersonSegmentationRequest()
        request.qualityLevel = .balanced // Keeps it running smooth at 30fps
        request.outputPixelFormat = kCVPixelFormatType_OneComponent8
        
        do {
            try requestHandler.perform([request], on: sampleBuffer)
            
            // 1. Get the solid mask (White person, Black background)
            guard let maskObservation = request.results?.first as? VNPixelBufferObservation else { return }
            let maskPixelBuffer = maskObservation.pixelBuffer
            
            let maskImage = CIImage(cvPixelBuffer: maskPixelBuffer)
            
            // 2. EDGE DETECTION: Trace the outline of the solid mask
            guard let edgesFilter = CIFilter(name: "CIEdges") else { return }
            edgesFilter.setValue(maskImage, forKey: kCIInputImageKey)
            edgesFilter.setValue(5.0, forKey: "inputIntensity") // Thickness of the line
            guard let outline = edgesFilter.outputImage else { return }
            
            // 3. TRANSPARENCY: Remove the black background so only the white line remains
            guard let alphaFilter = CIFilter(name: "CIMaskToAlpha") else { return }
            alphaFilter.setValue(outline, forKey: kCIInputImageKey)
            guard let transparentOutline = alphaFilter.outputImage else { return }
            
            // 4. Convert to a SwiftUI-friendly image and broadcast it
            if let cgImage = ciContext.createCGImage(transparentOutline, from: transparentOutline.extent) {
                DispatchQueue.main.async {
                    self.outlineImage = cgImage
                }
            }
            
        } catch {
            print("Vision request failed: \(error)")
        }
    }
}
