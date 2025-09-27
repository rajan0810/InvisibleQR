// Services/CameraManager.swift

import AVFoundation
import SwiftUI
import Combine

class CameraManager: NSObject, ObservableObject {
    
    let captureSession = AVCaptureSession()

    // We no longer call setupSession() in init()
    override init() {
        super.init()
    }
    
    // New public start method
    func start() {
        // We call setupSession here instead, ensuring it runs when needed.
        setupSession()
        
        // Ensure we're on the background thread to start the session.
        DispatchQueue.global(qos: .userInitiated).async {
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
        }
    }
    
    // New public stop method to be a good citizen and release the camera.
    func stop() {
        DispatchQueue.global(qos: .userInitiated).async {
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
        }
    }
    
    private func setupSession() {
        // Run session setup on a background thread.
        DispatchQueue.global(qos: .userInitiated).async {
            // Check if the session is already configured
            guard self.captureSession.inputs.isEmpty else { return }

            self.captureSession.beginConfiguration()
            self.captureSession.sessionPreset = .hd1920x1080

            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                // Added a print statement for debugging
                print("Error: Could not find back camera.")
                self.captureSession.commitConfiguration()
                return
            }
            
            guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
                  self.captureSession.canAddInput(videoDeviceInput) else {
                // Added a print statement for debugging
                print("Error: Could not create video device input.")
                self.captureSession.commitConfiguration()
                return
            }
            
            self.captureSession.addInput(videoDeviceInput)
            self.captureSession.commitConfiguration()
        }
    }
}
