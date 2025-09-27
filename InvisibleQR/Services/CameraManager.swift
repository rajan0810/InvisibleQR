// Services/CameraManager.swift

import AVFoundation
import SwiftUI
import Combine

class CameraManager: NSObject, ObservableObject {
    
    // This holds the live session from the camera.
    let captureSession = AVCaptureSession()

    override init() {
        super.init()
        setupSession()
    }
    
    private func setupSession() {
        // Run session setup on a background thread.
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.beginConfiguration()
            self.captureSession.sessionPreset = .hd1920x1080

            // Find the back camera.
            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
                  self.captureSession.canAddInput(videoDeviceInput) else {
                print("Error: Could not access back camera.")
                return
            }
            // Add the camera as an input to our session.
            self.captureSession.addInput(videoDeviceInput)
            self.captureSession.commitConfiguration()
            
            // Start the camera session.
            self.captureSession.startRunning()
        }
    }
}
