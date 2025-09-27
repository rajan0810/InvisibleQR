// Services/CameraManager.swift

import AVFoundation
import SwiftUI
import Combine

class CameraManager: NSObject, ObservableObject {
    
    let captureSession = AVCaptureSession()
    
    private let sessionQueue = DispatchQueue(label: "com.invisibleqr.sessionqueue")

    override init() {
        super.init()
    }
    
    func start() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            if self.captureSession.inputs.isEmpty {
                self.captureSession.beginConfiguration()
                
                // THIS IS THE FIX: Changed the incorrect preset name back to the correct one.
                self.captureSession.sessionPreset = .hd1920x1080
                
                guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                      let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
                      self.captureSession.canAddInput(videoDeviceInput) else {
                    print("Error: Could not access back camera or create input.")
                    self.captureSession.commitConfiguration()
                    return
                }
                
                self.captureSession.addInput(videoDeviceInput)
                self.captureSession.commitConfiguration()
            }
            
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
        }
    }
    
    func stop() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
        }
    }
}
