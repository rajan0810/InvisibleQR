// Services/CameraManager.swift

import AVFoundation
import SwiftUI
import Combine

class CameraManager: NSObject, ObservableObject {
    
    let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "com.invisibleqr.sessionqueue")

    override init() {
        super.init()
        checkPermissionAndStart()
    }
    
    /// Checks camera permission before starting session
    private func checkPermissionAndStart() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // Already authorized
            start()
        case .notDetermined:
            // Request permission
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.start()
                } else {
                    print("Camera access denied by user.")
                }
            }
        case .denied, .restricted:
            print("Camera access denied or restricted. Please enable it in Settings.")
        @unknown default:
            break
        }
    }
    
    func start() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            // Prevent reconfiguration if already set up
            guard self.captureSession.inputs.isEmpty else {
                if !self.captureSession.isRunning {
                    self.captureSession.startRunning()
                }
                return
            }

            self.captureSession.beginConfiguration()
            self.captureSession.sessionPreset = .hd1920x1080
            
            // Select the back wide-angle camera
            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
                  self.captureSession.canAddInput(videoDeviceInput) else {
                print("Error: Could not access back camera or create input.")
                self.captureSession.commitConfiguration()
                return
            }
            
            self.captureSession.addInput(videoDeviceInput)
            self.captureSession.commitConfiguration()
            
            // Start session on main thread
            DispatchQueue.main.async {
                if !self.captureSession.isRunning {
                    self.captureSession.startRunning()
                }
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
