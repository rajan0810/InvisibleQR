import CryptoKit
import Foundation

class CryptoService {
    private static let keyData = "InvisibleQR-Secret-Key-2024!@#$".data(using: .utf8)!
    private static let key = SymmetricKey(data: SHA256.hash(data: keyData))
    
    static func encrypt(_ message: String) -> Data {
        guard let messageData = message.data(using: .utf8) else {
            return Data()
        }
        
        do {
            let encryptedData = try AES.GCM.seal(messageData, using: key)
            return encryptedData.combined ?? Data()
        } catch {
            print("Encryption error: \(error)")
            return Data()
        }
    }
    
    static func decrypt(_ encryptedData: Data) -> String {
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
            let decryptedData = try AES.GCM.open(sealedBox, using: key)
            return String(data: decryptedData, encoding: .utf8) ?? "Decryption failed"
        } catch {
            print("Decryption error: \(error)")
            return "Could not decrypt message"
        }
    }
}
