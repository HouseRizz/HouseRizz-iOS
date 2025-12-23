//
//  VirtualStagingAPIService.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 21/12/24.
//

import Foundation

/// Service class for interacting with the Virtual Staging API
class VirtualStagingAPIService {
    static let shared = VirtualStagingAPIService()
    
    private let baseURL = "https://virtual-staging-api-wmggns3mvq-uc.a.run.app"
    private let session: URLSession
    
    // MARK: - Caching for Development/Testing
    /// Set to true to use cached response instead of calling API
    var useCachedResponse = false
    private var cachedResponse: DesignResponse?
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 600 // 10 minutes - design + segmentation takes time
        config.timeoutIntervalForResource = 600 // 10 minutes
        self.session = URLSession(configuration: config)
    }
    
    /// Clear the cached response
    func clearCache() {
        cachedResponse = nil
    }
    
    /// Design a room with the given image and vibe, including segmentation
    /// - Parameters:
    ///   - imageData: The room image data
    ///   - vibe: The desired design vibe/style
    ///   - runSegmentation: Whether to run furniture segmentation on generated image
    /// - Returns: DesignResponse containing the generated image URL and detected objects
    func designRoom(imageData: Data, vibe: String, runSegmentation: Bool = true) async throws -> DesignResponse {
        // Return cached response if available and caching is enabled
        if useCachedResponse, let cached = cachedResponse {
            print("📦 Using cached API response")
            return cached
        }
        
        guard let url = URL(string: "\(baseURL)/design/upload-with-segmentation") else {
            throw VirtualStagingError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let base64Image = imageData.base64EncodedString()
        let requestBody = DesignRequest(
            roomImageBase64: base64Image,
            mimeType: "image/jpeg",
            vibeText: vibe,
            runSegmentation: runSegmentation
        )
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(requestBody)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw VirtualStagingError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            // Try to decode error message
            if let errorMessage = String(data: data, encoding: .utf8) {
                throw VirtualStagingError.serverError(statusCode: httpResponse.statusCode, message: errorMessage)
            }
            throw VirtualStagingError.serverError(statusCode: httpResponse.statusCode, message: "Unknown error")
        }
        
        let decoder = JSONDecoder()
        let designResponse = try decoder.decode(DesignResponse.self, from: data)
        
        // Cache the successful response
        cachedResponse = designResponse
        print("📦 Cached API response (matchedLabels: \(designResponse.matchedLabels ?? []))")
        
        return designResponse
    }
    
    /// Check if the API is healthy
    func healthCheck() async throws -> Bool {
        guard let url = URL(string: "\(baseURL)/health") else {
            throw VirtualStagingError.invalidURL
        }
        
        let (_, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            return false
        }
        
        return httpResponse.statusCode == 200
    }
}

/// Errors that can occur when using the Virtual Staging API
enum VirtualStagingError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int, message: String)
    case encodingError
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .serverError(let statusCode, let message):
            return "Server error (\(statusCode)): \(message)"
        case .encodingError:
            return "Failed to encode request"
        case .decodingError:
            return "Failed to decode response"
        }
    }
}
