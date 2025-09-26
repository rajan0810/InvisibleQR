import AVFoundation
import UIKit
import Combine

class CameraManager: NSObject, ObservableObject {
    @Published var session = AVCaptureSession()
    @Published var previewLayer: AVCaptureVideoPreviewLayer?
    @Published var isSessionRunning = false
    @Published var currentFrame: UIImage?
    
    private let output = AVCaptureVideoDataOutput()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    override init() {
        super.init()
        setupCamera()
    }
    
    private func setupCamera() {
        sessionQueue.async { [weak self] in
            self?.configureCaptureSession()
        }
    }
    
    private func configureCaptureSession() {
        session.beginConfiguration()
        
        // Add camera input
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else {
            print("Failed to create camera input")
            return
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        // Add video output
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "video.output.queue"))
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        // Set session preset
        session.sessionPreset = .photo
        session.commitConfiguration()
        
        // Create preview layer
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
            self.previewLayer?.videoGravity = .resizeAspectFill
        }
    }
    
    func startSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if !self.session.isRunning {
                self.session.startRunning()
                DispatchQueue.main.async {
                    self.isSessionRunning = true
                }
            }
        }
    }
    
    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if self.session.isRunning {
                self.session.stopRunning()
                DispatchQueue.main.async {
                    self.isSessionRunning = false
                }
            }
        }
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let image = UIImage.fromPixelBuffer(pixelBuffer)
        
        DispatchQueue.main.async { [weak self] in
            self?.currentFrame = image
        }
    }
}

// ==========================================
// 9. CRYPTO SERVICE
// ==========================================

import CryptoKit
import Foundation

class CryptoService {
    private static let key = SymmetricKey(size: .bits256)
    
    static func encrypt(_ message: String) -> Data {
        guard let data = message.data(using: .utf8) else {
            return Data()
        }
        
        do {
            let encryptedData = try AES.GCM.seal(data, using: key)
            return encryptedData.combined ?? Data()
        } catch {
            print("Encryption error: \(error)")
            return Data()
        }
    }
    
    static func decrypt(_ encryptedData: Data) -> String {
        do {
            let box = try AES.GCM.SealedBox(combined: encryptedData)
            let decryptedData = try AES.GCM.open(box, using: key)
            return String(data: decryptedData, encoding: .utf8) ?? ""
        } catch {
            print("Decryption error: \(error)")
            return ""
        }
    }
}
