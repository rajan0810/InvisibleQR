import SwiftUI
import AVFoundation

struct CameraView: UIViewRepresentable {
    @StateObject private var cameraManager = CameraManager()
    @Binding var capturedImage: UIImage?
    @Binding var isAnalyzing: Bool
    
    func makeUIView(context: Context) -> CameraPreviewView {
        let view = CameraPreviewView()
        view.cameraManager = cameraManager
        return view
    }
    
    func updateUIView(_ uiView: CameraPreviewView, context: Context) {
        // Update UI if needed
        if let image = cameraManager.currentFrame {
            capturedImage = image
        }
    }
    
    static func dismantleUIView(_ uiView: CameraPreviewView, coordinator: ()) {
        uiView.cameraManager?.stopSession()
    }
}

class CameraPreviewView: UIView {
    var cameraManager: CameraManager?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let cameraManager = cameraManager,
              let previewLayer = cameraManager.previewLayer else { return }
        
        previewLayer.frame = bounds
        
        if previewLayer.superlayer == nil {
            layer.addSublayer(previewLayer)
            cameraManager.startSession()
        }
    }
}

// Simple Camera Manager for quick setup
class CameraManager: NSObject, ObservableObject {
    @Published var session = AVCaptureSession()
    @Published var previewLayer: AVCaptureVideoPreviewLayer?
    @Published var currentFrame: UIImage?
    
    private let output = AVCaptureVideoDataOutput()
    
    override init() {
        super.init()
        checkPermissions()
    }
    
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.setupCamera()
                    }
                }
            }
        default:
            print("Camera access denied")
        }
    }
    
    private func setupCamera() {
        session.beginConfiguration()
        
        // Add camera input
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else {
            print("Failed to create camera input")
            return
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        // Add video output
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera.frame.queue"))
        
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        session.sessionPreset = .high
        session.commitConfiguration()
        
        // Create preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.videoGravity = .resizeAspectFill
    }
    
    func startSession() {
        if !session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                self.session.startRunning()
            }
        }
    }
    
    func stopSession() {
        if session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                self.session.stopRunning()
            }
        }
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        // Convert to UIImage (simplified version)
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
        let image = UIImage(cgImage: cgImage)
        
        DispatchQueue.main.async {
            self.currentFrame = image
        }
    }
}
