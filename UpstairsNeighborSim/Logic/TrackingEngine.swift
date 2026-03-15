import Foundation
import Vision
import AVFoundation
import Combine

class TrackingEngine: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var handGroups: [[CGPoint]] = []
    @Published var handCount: Int = 0
    
    let session = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    
    override init() {
        super.init()
        prepareCamera()
    }
    
    private func prepareCamera() {
        session.beginConfiguration()
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else {
            session.commitConfiguration()
            return
        }
        if session.canAddInput(input) { session.addInput(input) }
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        if session.canAddOutput(videoOutput) { session.addOutput(videoOutput) }
        session.commitConfiguration()
    }
    
    func start() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            if !self.session.isRunning { self.session.startRunning() }
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up)
        let request = VNDetectHumanHandPoseRequest()
        request.maximumHandCount = 2 // Detect both hands
        
        do {
            try handler.perform([request])
            var newHandGroups: [[CGPoint]] = []
            
            if let observations = request.results {
                for observation in observations {
                    let points = try observation.recognizedPoints(.all)
                    let mapped = points.values
                        .filter { $0.confidence > 0.3 }
                        .map { $0.location }
                    if !mapped.isEmpty { newHandGroups.append(mapped) }
                }
            }
            
            DispatchQueue.main.async {
                self.handGroups = newHandGroups
                self.handCount = newHandGroups.count
            }
        } catch {
            print("Vision Error: \(error)")
        }
    }
}
