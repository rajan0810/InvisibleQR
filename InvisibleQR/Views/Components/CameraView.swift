// Views/Components/CameraView.swift

import SwiftUI
import AVFoundation

struct CameraView: UIViewRepresentable {
    var cameraManager: CameraManager
    
    func makeUIView(context: Context) -> UIView {
        // Initialize with a zero frame and let SwiftUI manage the layout.
        let view = UIView(frame: .zero)
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: cameraManager.captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        
        // Add the layer to our view.
        view.layer.addSublayer(previewLayer)
        
        return view
    }
    
    // This ensures the previewLayer's frame always matches the view's frame.
    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = uiView.bounds
        }
    }
}
