// Services/NetworkManager.swift

import Foundation
import Supabase

// Models to match the database table and RPC response
struct TextureMessage: Encodable {
    let feature_vector: [Float]
    let encrypted_message: String
}

struct FindMessageResponse: Decodable {
    let found: Bool
    let encryptedMessage: String?
    let similarity: Double?
}

// A simpler struct for the actual RPC call result
struct RPCResult: Decodable {
    let encrypted_message: String
    let similarity: Float
}


class NetworkManager {
    static let shared = NetworkManager()
    
    // IMPORTANT: Replace with your Supabase URL and Anon Key
    private let supabase = SupabaseClient(
      supabaseURL: URL(string: "https://nypszvpheqjnzvavrlhr.supabase.co")!,
      supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im55cHN6dnBoZXFqbnp2YXZybGhyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg5MjkwMTYsImV4cCI6MjA3NDUwNTAxNn0.ErkUnvPeOkGxXU5NOm4Skf4mMJdVrTK-Utb9_MST2NM"
    )

    func hideMessage(featureVector: [Float], encryptedMessage: String) async throws {
        let message = TextureMessage(feature_vector: featureVector, encrypted_message: encryptedMessage)
        try await supabase.from("texture_messages").insert(message).execute()
    }
    
    func findSimilarMessage(featureVector: [Float]) async throws -> FindMessageResponse {
        let result: [RPCResult] = try await supabase.rpc("find_similar_message", params: ["query_vector": featureVector]).execute().value
        
        if let bestMatch = result.first {
            return FindMessageResponse(
                found: true,
                encryptedMessage: bestMatch.encrypted_message,
                similarity: Double(bestMatch.similarity)
            )
        } else {
            return FindMessageResponse(found: false, encryptedMessage: nil, similarity: nil)
        }
    }
}
