// Services/CameraManager.swift

import AVFoundation
import SwiftUI
import Combine

class CameraManager: NSObject, ObservableObject {
    
    let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "com.invisibleqr.sessionqueue")

    override init() {
        super.init()
        // We now start the camera setup as soon as the manager is created.
        checkPermissionAndStart()
    }
    
    private func checkPermissionAndStart() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // Permission already granted.
            self.setupSession()
        case .notDetermined:
            // Request permission.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.setupSession()
                }
            }
        default:
            // Permission denied.
            print("Camera access denied or restricted.")
        }
    }
    
    private func setupSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.captureSession.beginConfiguration()
            self.captureSession.sessionPreset = .hd1920x1080
            
            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
                  self.captureSession.canAddInput(videoDeviceInput) else {
                self.captureSession.commitConfiguration()
                return
            }
            
            self.captureSession.addInput(videoDeviceInput)
            self.captureSession.commitConfiguration()
            
            // We now start the session here and leave it running.
            self.captureSession.startRunning()
        }
    }
}
