// Services/CryptoService.swift

import CryptoKit
import Foundation

class CryptoService {
    // IMPORTANT: For a real app, generate this key securely.
    // For a hackathon, a hardcoded key is okay. It MUST be 32 characters.
    private let key = SymmetricKey(data: "this-is-my-super-secret-key!!123".data(using: .utf8)!)

    func encrypt(_ message: String) throws -> String? {
        guard let data = message.data(using: .utf8) else { return nil }
        let sealedBox = try AES.GCM.seal(data, using: key)
        return sealedBox.combined?.base64EncodedString()
    }
    
    func decrypt(_ base64Encrypted: String) throws -> String? {
        guard let data = Data(base64Encoded: base64Encrypted),
              let sealedBox = try? AES.GCM.SealedBox(combined: data) else {
            return nil
        }
        let decryptedData = try AES.GCM.open(sealedBox, using: key)
        return String(data: decryptedData, encoding: .utf8)
    }
}
