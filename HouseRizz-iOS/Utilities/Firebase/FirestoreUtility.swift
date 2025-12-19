//
//  FirestoreUtility.swift
//  HouseRizz-iOS
//
//  Created for CloudKit to Firebase migration.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage
import Combine

// MARK: - Protocol

protocol FirestorableProtocol: Codable, Identifiable where ID == UUID {
    var id: UUID { get }
    static var collectionName: String { get }
}

// MARK: - FirestoreUtility

class FirestoreUtility {
    
    static let shared = FirestoreUtility()
    private let db: Firestore
    private let storage: Storage
    
    private init() {
        db = Firestore.firestore()
        storage = Storage.storage()
    }
    
    enum FirestoreError: LocalizedError {
        case encodingError
        case decodingError
        case documentNotFound
        case uploadFailed
        case downloadFailed
        
        var errorDescription: String? {
            switch self {
            case .encodingError: return "Failed to encode data"
            case .decodingError: return "Failed to decode data"
            case .documentNotFound: return "Document not found"
            case .uploadFailed: return "File upload failed"
            case .downloadFailed: return "File download failed"
            }
        }
    }
}

// MARK: - CRUD Operations

extension FirestoreUtility {
    
    /// Fetch all documents from a collection
    static func fetch<T: FirestorableProtocol>(
        sortBy: String? = nil,
        ascending: Bool = true,
        limit: Int? = nil
    ) -> AnyPublisher<[T], Error> {
        Deferred {
            Future<[T], Error> { promise in
                var query: Query = shared.db.collection(T.collectionName)
                
                if let sortField = sortBy {
                    query = query.order(by: sortField, descending: !ascending)
                }
                
                if let resultLimit = limit {
                    query = query.limit(to: resultLimit)
                }
                
                query.getDocuments { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        promise(.success([]))
                        return
                    }
                    
                    let items: [T] = documents.compactMap { doc in
                        try? doc.data(as: T.self)
                    }
                    promise(.success(items))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    /// Fetch documents with a predicate (field equals value)
    static func fetch<T: FirestorableProtocol>(
        field: String,
        isEqualTo value: Any,
        sortBy: String? = nil,
        ascending: Bool = true,
        limit: Int? = nil
    ) -> AnyPublisher<[T], Error> {
        Deferred {
            Future<[T], Error> { promise in
                var query: Query = shared.db.collection(T.collectionName)
                    .whereField(field, isEqualTo: value)
                
                if let sortField = sortBy {
                    query = query.order(by: sortField, descending: !ascending)
                }
                
                if let resultLimit = limit {
                    query = query.limit(to: resultLimit)
                }
                
                query.getDocuments { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        promise(.success([]))
                        return
                    }
                    
                    let items: [T] = documents.compactMap { doc in
                        try? doc.data(as: T.self)
                    }
                    promise(.success(items))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    /// Fetch documents with array contains query
    static func fetch<T: FirestorableProtocol>(
        field: String,
        arrayContains value: Any
    ) -> AnyPublisher<[T], Error> {
        Deferred {
            Future<[T], Error> { promise in
                shared.db.collection(T.collectionName)
                    .whereField(field, arrayContains: value)
                    .getDocuments { snapshot, error in
                        if let error = error {
                            promise(.failure(error))
                            return
                        }
                        
                        guard let documents = snapshot?.documents else {
                            promise(.success([]))
                            return
                        }
                        
                        let items: [T] = documents.compactMap { doc in
                            try? doc.data(as: T.self)
                        }
                        promise(.success(items))
                    }
            }
        }.eraseToAnyPublisher()
    }
    
    /// Add or update an item
    static func add<T: FirestorableProtocol>(item: T, completion: @escaping (Result<Bool, Error>) -> Void) {
        do {
            try shared.db.collection(T.collectionName)
                .document(item.id.uuidString)
                .setData(from: item) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(true))
                    }
                }
        } catch {
            completion(.failure(error))
        }
    }
    
    /// Update an item (same as add with merge)
    static func update<T: FirestorableProtocol>(item: T, completion: @escaping (Result<Bool, Error>) -> Void) {
        add(item: item, completion: completion)
    }
    
    /// Delete an item
    static func delete<T: FirestorableProtocol>(item: T) -> AnyPublisher<Bool, Error> {
        Deferred {
            Future<Bool, Error> { promise in
                shared.db.collection(T.collectionName)
                    .document(item.id.uuidString)
                    .delete { error in
                        if let error = error {
                            promise(.failure(error))
                        } else {
                            promise(.success(true))
                        }
                    }
            }
        }.eraseToAnyPublisher()
    }
    
    /// Delete by ID
    static func delete<T: FirestorableProtocol>(type: T.Type, id: UUID) -> AnyPublisher<Bool, Error> {
        Deferred {
            Future<Bool, Error> { promise in
                shared.db.collection(T.collectionName)
                    .document(id.uuidString)
                    .delete { error in
                        if let error = error {
                            promise(.failure(error))
                        } else {
                            promise(.success(true))
                        }
                    }
            }
        }.eraseToAnyPublisher()
    }
}

// MARK: - Firebase Storage Operations

extension FirestoreUtility {
    
    /// Upload image data to Firebase Storage
    static func uploadImage(
        data: Data,
        path: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let storageRef = shared.storage.reference().child(path)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        storageRef.putData(data, metadata: metadata) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                } else if let downloadURL = url {
                    completion(.success(downloadURL.absoluteString))
                } else {
                    completion(.failure(FirestoreError.uploadFailed))
                }
            }
        }
    }
    
    /// Upload file from local URL to Firebase Storage
    static func uploadFile(
        from localURL: URL,
        to path: String,
        contentType: String = "application/octet-stream",
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let storageRef = shared.storage.reference().child(path)
        let metadata = StorageMetadata()
        metadata.contentType = contentType
        
        storageRef.putFile(from: localURL, metadata: metadata) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                } else if let downloadURL = url {
                    completion(.success(downloadURL.absoluteString))
                } else {
                    completion(.failure(FirestoreError.uploadFailed))
                }
            }
        }
    }
    
    /// Delete file from Firebase Storage
    static func deleteFile(path: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let storageRef = shared.storage.reference().child(path)
        storageRef.delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    /// Download file to local filesystem
    static func downloadFile(from path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let storageRef = shared.storage.reference().child(path)
        let localURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        
        storageRef.write(toFile: localURL) { url, error in
            if let error = error {
                completion(.failure(error))
            } else if let fileURL = url {
                completion(.success(fileURL))
            } else {
                completion(.failure(FirestoreError.downloadFailed))
            }
        }
    }
}

// MARK: - Async/Await Support

extension FirestoreUtility {
    
    /// Async fetch all documents
    static func fetch<T: FirestorableProtocol>(
        sortBy: String? = nil,
        ascending: Bool = true,
        limit: Int? = nil
    ) async throws -> [T] {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            let publisher: AnyPublisher<[T], Error> = fetch(sortBy: sortBy, ascending: ascending, limit: limit)
            cancellable = publisher.sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()
                },
                receiveValue: { items in
                    continuation.resume(returning: items)
                }
            )
        }
    }
    
    /// Async fetch with predicate
    static func fetch<T: FirestorableProtocol>(
        field: String,
        isEqualTo value: Any,
        sortBy: String? = nil,
        ascending: Bool = true,
        limit: Int? = nil
    ) async throws -> [T] {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            let publisher: AnyPublisher<[T], Error> = fetch(field: field, isEqualTo: value, sortBy: sortBy, ascending: ascending, limit: limit)
            cancellable = publisher.sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()
                },
                receiveValue: { items in
                    continuation.resume(returning: items)
                }
            )
        }
    }
    
    /// Async add item
    static func add<T: FirestorableProtocol>(item: T) async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            add(item: item) { result in
                switch result {
                case .success(let success):
                    continuation.resume(returning: success)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// Async upload image
    static func uploadImage(data: Data, path: String) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            uploadImage(data: data, path: path) { result in
                switch result {
                case .success(let url):
                    continuation.resume(returning: url)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// Async upload file
    static func uploadFile(from localURL: URL, to path: String, contentType: String = "application/octet-stream") async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            uploadFile(from: localURL, to: path, contentType: contentType) { result in
                switch result {
                case .success(let url):
                    continuation.resume(returning: url)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
