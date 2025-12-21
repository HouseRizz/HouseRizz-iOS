//
//  FurnitureSegmentation.swift
//  
//  Furniture segmentation and highlighting using Virtual Staging API
//  This file can be added to a SwiftUI project to enable furniture detection and greying.
//

import Foundation
import UIKit
import CoreGraphics

// MARK: - API Models

struct SegmentRequest: Codable {
    let image_base64: String
    let use_sam_hq: Bool
    
    enum CodingKeys: String, CodingKey {
        case image_base64 = "image_base64"
        case use_sam_hq = "use_sam_hq"
    }
}

struct DetectedObject: Codable, Identifiable {
    var id: String { "\(label)_\(value)" }
    let label: String
    let box: [Double]  // [x1, y1, x2, y2]
    let confidence: Double
    let value: Int
}

struct SegmentResponse: Codable {
    let masked_img: String
    let visualization_img: String
    let tags: String
    let objects: [DetectedObject]
}

// MARK: - Segmentation API Client

class SegmentationAPI {
    static let shared = SegmentationAPI()
    
    // TODO: Update this URL after deploying
    var baseURL = "https://virtual-staging-api-wmggns3mvq-uc.a.run.app"
    
    private init() {}
    
    /// Segment all objects in an image
    func segment(imageData: Data, useSamHQ: Bool = false) async throws -> SegmentResponse {
        let request = SegmentRequest(
            image_base64: imageData.base64EncodedString(),
            use_sam_hq: useSamHQ
        )
        
        guard let url = URL(string: "\(baseURL)/segment") else {
            throw SegmentationError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.timeoutInterval = 120  // Segmentation can take time
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            throw SegmentationError.encodingError(error)
        }
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SegmentationError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw SegmentationError.serverError(httpResponse.statusCode, errorMessage)
        }
        
        return try JSONDecoder().decode(SegmentResponse.self, from: data)
    }
    
    /// Download mask image from URL
    func downloadMask(from urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString) else {
            throw SegmentationError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard let image = UIImage(data: data) else {
            throw SegmentationError.imageDecodingFailed
        }
        
        return image
    }
    
    /// Find an object by label in the response
    func findObject(label: String, in response: SegmentResponse) -> DetectedObject? {
        return response.objects.first { 
            $0.label.lowercased().contains(label.lowercased()) 
        }
    }
}

// MARK: - Errors

enum SegmentationError: LocalizedError {
    case invalidURL
    case encodingError(Error)
    case invalidResponse
    case serverError(Int, String)
    case imageDecodingFailed
    case processingFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .encodingError(let error):
            return "Failed to encode request: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid server response"
        case .serverError(let code, let message):
            return "Server error (\(code)): \(message)"
        case .imageDecodingFailed:
            return "Failed to decode image"
        case .processingFailed:
            return "Image processing failed"
        }
    }
}

extension UIImage {
    
    /// Grey out pixels that match a specific color region from the mask
    /// - Parameters:
    ///   - mask: The segmentation mask image
    ///   - box: Bounding box [x1, y1, x2, y2] in original image coordinates
    ///   - tolerance: Color matching tolerance (0-255)
    /// - Returns: Image with the region greyed out
    func greyOutRegion(mask: UIImage, box: [Double], tolerance: CGFloat = 20) -> UIImage? {
        guard let originalCG = self.cgImage else { 
            print("Failed to get original CGImage")
            return nil 
        }
        
        let width = originalCG.width
        let height = originalCG.height
        
        // Resize mask to match original image size FIRST
        guard let resizedMask = mask.resize(to: CGSize(width: width, height: height)),
              let resizedCG = resizedMask.cgImage else { 
            print("Failed to resize mask")
            return nil 
        }
        
        // Create a standard RGBA context for the mask
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        guard let maskContext = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else { 
            print("Failed to create mask context")
            return nil 
        }
        
        // Draw mask into standardized context
        maskContext.draw(resizedCG, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let maskData = maskContext.data else { 
            print("Failed to get mask data")
            return nil 
        }
        let maskPixels = maskData.bindMemory(to: UInt8.self, capacity: width * height * 4)
        
        // Sample the target color from center of bounding box
        let boxX1 = max(0, Int(box[0]))
        let boxY1 = max(0, Int(box[1]))
        let boxX2 = min(width, Int(box[2]))
        let boxY2 = min(height, Int(box[3]))
        
        // Find the MOST COMMON (dominant) color in the box region - like Python does
        var colorCounts: [String: (r: CGFloat, g: CGFloat, b: CGFloat, count: Int)] = [:]
        
        for y in boxY1..<boxY2 {
            for x in boxX1..<boxX2 {
                let idx = y * width * 4 + x * 4
                let r = Int(maskPixels[idx])
                let g = Int(maskPixels[idx + 1])
                let b = Int(maskPixels[idx + 2])
                
                // Skip black/near-black (background)
                if r + g + b > 30 {
                    // Quantize to reduce variations (like Python's exact matching)
                    let qr = (r / 5) * 5
                    let qg = (g / 5) * 5
                    let qb = (b / 5) * 5
                    let key = "\(qr),\(qg),\(qb)"
                    
                    if var existing = colorCounts[key] {
                        existing.count += 1
                        colorCounts[key] = existing
                    } else {
                        colorCounts[key] = (CGFloat(r), CGFloat(g), CGFloat(b), 1)
                    }
                }
            }
        }
        
        // Find the most common color
        guard let dominantEntry = colorCounts.values.max(by: { $0.count < $1.count }) else {
            print("Could not find any non-background color in box region")
            return nil
        }
        
        let targetR = dominantEntry.r
        let targetG = dominantEntry.g
        let targetB = dominantEntry.b
        print("Found dominant color: R=\(targetR), G=\(targetG), B=\(targetB) with \(dominantEntry.count) pixels")
        
        // Create output context with original image
        guard let outputContext = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else { 
            print("Failed to create output context")
            return nil 
        }
        
        outputContext.draw(originalCG, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let outputData = outputContext.data else { 
            print("Failed to get output data")
            return nil 
        }
        let outputPixels = outputData.bindMemory(to: UInt8.self, capacity: width * height * 4)
        
        // Process only pixels WITHIN the bounding box
        // Use strict tolerance like Python (cv2.inRange with tolerance 15)
        let strictTolerance: CGFloat = 10  // Stricter than parameter to avoid catching similar colors
        var matchedPixels = 0
        let safeBoxX1 = max(0, boxX1)
        let safeBoxY1 = max(0, boxY1)
        let safeBoxX2 = min(width, boxX2)
        let safeBoxY2 = min(height, boxY2)
        
        print("Processing box: (\(safeBoxX1), \(safeBoxY1)) to (\(safeBoxX2), \(safeBoxY2))")
        print("Target color: R=\(targetR), G=\(targetG), B=\(targetB), tolerance=\(strictTolerance)")
        
        for y in safeBoxY1..<safeBoxY2 {
            for x in safeBoxX1..<safeBoxX2 {
                let idx = y * width * 4 + x * 4
                
                let r = CGFloat(maskPixels[idx])
                let g = CGFloat(maskPixels[idx + 1])
                let b = CGFloat(maskPixels[idx + 2])
                
                // Check if pixel matches target color (within strict tolerance)
                if abs(r - targetR) <= strictTolerance &&
                   abs(g - targetG) <= strictTolerance &&
                   abs(b - targetB) <= strictTolerance {
                    
                    // Convert to grayscale using luminosity method
                    let gray = UInt8(
                        0.299 * Double(outputPixels[idx]) +
                        0.587 * Double(outputPixels[idx + 1]) +
                        0.114 * Double(outputPixels[idx + 2])
                    )
                    
                    outputPixels[idx] = gray
                    outputPixels[idx + 1] = gray
                    outputPixels[idx + 2] = gray
                    // Keep alpha unchanged
                    matchedPixels += 1
                }
            }
        }
        
        print("Greyed out \(matchedPixels) pixels")
        
        guard let outputImage = outputContext.makeImage() else { 
            print("Failed to create output image")
            return nil 
        }
        return UIImage(cgImage: outputImage, scale: self.scale, orientation: self.imageOrientation)
    }
    
    /// Resize image to specified size
    func resize(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

// MARK: - High-Level Helper

extension SegmentationAPI {
    
    /// Complete workflow: segment image and grey out a specific object
    /// - Parameters:
    ///   - image: The original image
    ///   - targetLabel: Label to search for (e.g., "couch", "sofa")
    /// - Returns: Processed image with object greyed out
    func greyOutObject(in image: UIImage, targetLabel: String) async throws -> UIImage {
        // 1. Convert to JPEG data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw SegmentationError.processingFailed
        }
        
        // 2. Call segmentation API
        let response = try await segment(imageData: imageData)
        
        // 3. Find target object
        guard let targetObject = findObject(label: targetLabel, in: response) else {
            print("Object '\(targetLabel)' not found. Available: \(response.objects.map { $0.label })")
            throw SegmentationError.processingFailed
        }
        
        // 4. Download mask
        let mask = try await downloadMask(from: response.masked_img)
        
        // 5. Apply grey effect
        guard let result = image.greyOutRegion(mask: mask, box: targetObject.box) else {
            throw SegmentationError.processingFailed
        }
        
        return result
    }
}
