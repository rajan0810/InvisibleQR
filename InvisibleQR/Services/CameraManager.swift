// Services/CameraManager.swift

import AVFoundation
import SwiftUI
import Combine
import CoreImage

class CameraManager: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // The @Published property is now a CGImage, which is thread-safe.
    @Published var capturedFrame: CGImage?
    
    let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let sessionQueue = DispatchQueue(label: "com.invisibleqr.sessionqueue")
    private let context = CIContext()

    override init() {
        super.init()
        checkPermissionAndStart()
    }
    
    private func checkPermissionAndStart() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.setupSession()
                }
            }
        default:
            print("Camera access denied.")
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
            
            self.videoOutput.setSampleBufferDelegate(self, queue: self.sessionQueue)
            guard self.captureSession.canAddOutput(self.videoOutput) else {
                self.captureSession.commitConfiguration()
                return
            }
            self.captureSession.addOutput(self.videoOutput)
            
            self.captureSession.commitConfiguration()
            self.captureSession.startRunning()
        }
    }
    
    nonisolated func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        // On the background thread, convert the unsafe CVPixelBuffer to a safe CGImage.
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        guard let cgImage = self.context.createCGImage(ciImage, from: ciImage.extent) else { return }
        
        // Now, safely dispatch the CGImage to the main thread.
        DispatchQueue.main.async {
            self.capturedFrame = cgImage
        }
    }
}
