// Services/CameraManager.swift

import AVFoundation
import SwiftUI
import Combine

class CameraManager: NSObject, ObservableObject {
    
    let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "com.invisibleqr.sessionqueue")

    override init() {
        super.init()
        // Start camera session immediately when CameraManager is created
        start()
    }
    
    func start() {
        // We do the heavy configuration on our background queue.
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            // Only configure the session if it hasn't been done already.
            guard self.captureSession.inputs.isEmpty else {
                // If already configured, just ensure it's running.
                if !self.captureSession.isRunning {
                    self.captureSession.startRunning()
                }
                return
            }

            self.captureSession.beginConfiguration()
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
            
            // Now that configuration is complete on the background thread,
            // we dispatch the startRunning command back to the main thread.
            DispatchQueue.main.async {
                if !self.captureSession.isRunning {
                    self.captureSession.startRunning()
                }
            }
        }
    }
    
    func stop() {
        // We don’t really need to stop during tab switches anymore,
        // but you can call this if you want to stop when app goes background.
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
        }
    }
}
