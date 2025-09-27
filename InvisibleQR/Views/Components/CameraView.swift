// Views/Components/CameraView.swift

import SwiftUI
import AVFoundation

struct CameraView: UIViewRepresentable {
    var cameraManager: CameraManager
    
    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        
        // Attach the same shared session
        if view.videoPreviewLayer.session == nil {
            view.videoPreviewLayer.session = cameraManager.captureSession
        }
        
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }
    
    func updateUIView(_ uiView: PreviewView, context: Context) {
        uiView.videoPreviewLayer.frame = uiView.bounds
    }
}

/// A UIView subclass backed by AVCaptureVideoPreviewLayer
final class PreviewView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}
