//  RealtimeDatabaseManager.swift
//  Created by Krish Mittal.

import Foundation
import Firebase
import FirebaseDatabase

/// A manager class for handling Firebase Realtime Database operations.
class RealtimeDatabaseManager {
    /// Shared instance of the RealtimeDatabaseManager.
    static let shared = RealtimeDatabaseManager()
    
    let db: DatabaseReference
    
    private init() { db = Database.database().reference() }
    
    var currentHandle: DatabaseHandle?
}

// MARK: - Generic CRUD Operations

extension RealtimeDatabaseManager {
    
    /// Creates a new document in the specified collection with a UUID as the document ID.
    /// - Parameters:
    ///   - path: The path of the collection to add the document to.
    ///   - data: The data to be stored in the new document.
    ///   - completion: A closure that gets called with the result of the operation.
    func create<T: Codable>(path: String, data: T, id: String? = nil, completion: @escaping (Result<String, Error>) -> Void) {
        guard !path.isEmpty else {
            completion(.failure(NSError(domain: "InvalidPath", code: 400, userInfo: [NSLocalizedDescriptionKey: "Path cannot be empty."])))
            return
        }
        
        do {
            let encodedData = try JSONEncoder().encode(data)
            let dictionary = try JSONSerialization.jsonObject(with: encodedData, options: .allowFragments) as? [String: Any] ?? [:]
            
            let documentId = id ?? UUID().uuidString
            db.child(path).child(documentId).setValue(dictionary) { error, _ in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(documentId))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    /// Reads a document from the specified collection.
    /// - Parameters:
    ///   - path: The path of the collection containing the document.
    ///   - documentId: The ID of the document to read.
    ///   - type: The type to decode the document data into.
    ///   - completion: A closure that gets called with the result of the operation.
    func read<T: Codable>(path: String, documentId: String, as type: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        guard !path.isEmpty, !documentId.isEmpty else {
            completion(.failure(NSError(domain: "InvalidInput", code: 400, userInfo: [NSLocalizedDescriptionKey: "Path and Document ID cannot be empty."])))
            return
        }
        
        db.child(path).child(documentId).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Document not found"])))
                return
            }
            
            do {
                let data = try JSONSerialization.data(withJSONObject: value)
                let object = try JSONDecoder().decode(T.self, from: data)
                completion(.success(object))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    /// Updates a document in the specified collection.
    /// - Parameters:
    ///   - path: The path of the collection containing the document.
    ///   - documentId: The ID of the document to update.
    ///   - data: The new data to update the document with.
    ///   - completion: A closure that gets called with the result of the operation.
    func update<T: Codable>(path: String, documentId: String, data: T, completion: @escaping (Result<Bool, Error>) -> Void) {
            do {
                let encodedData = try JSONEncoder().encode(data)
                let dictionary = try JSONSerialization.jsonObject(with: encodedData, options: .allowFragments) as? [String: Any] ?? [:]

                db.child(path).child(documentId).updateChildValues(dictionary) { error, _ in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success((true)))
                    }
                }
            } catch {
                completion(.failure(error))
            }
        }
    
    /// Deletes a document from the specified collection.
    /// - Parameters:
    ///   - path: The path of the collection containing the document.
    ///   - documentId: The ID of the document to delete.
    ///   - completion: A closure that gets called with the result of the operation.
    func delete(path: String, documentId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard !path.isEmpty, !documentId.isEmpty else {
            completion(.failure(NSError(domain: "InvalidInput", code: 400, userInfo: [NSLocalizedDescriptionKey: "Path and Document ID cannot be empty."])))
            return
        }
        
        db.child(path).child(documentId).removeValue { error, _ in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}

// MARK: - Listener Functions

extension RealtimeDatabaseManager {
    func queryDocuments(collectionPath: String, field: String, subField: String, arrayContains value: Any, completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
            let ref = Database.database().reference().child(collectionPath)

            // Retrieve all documents from the specified collection path
        ref.observe(.value)  { snapshot in
                guard let allData = snapshot.value as? [String: [String: Any]] else {
                    completion(.success([])) // Return empty if no data is found
                    return
                }

                // Filter the documents where the field contains the specified value
                let filteredData = allData.values.filter { document in
                    if let arrayField = document[field] as? [[String: Any]] {
                        return arrayField.contains { $0[subField] as? String == value as? String }
                    }
                    return false
                }

                completion(.success(filteredData.isEmpty ? [] : filteredData))
            } withCancel: { error in
                completion(.failure(error))
            }
        }
    /// Observes changes to a specific document.
    /// - Parameters:
    ///   - path: The path of the collection containing the document.
    ///   - documentId: The ID of the document to listen to.
    ///   - completion: A closure that gets called with the document snapshot or error.
    func observeDocument<T: Codable>(path: String, documentId: String, as type: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        db.child(path).child(documentId).observe(.value) { snapshot in
            guard !path.isEmpty, !documentId.isEmpty else {
                completion(.failure(NSError(domain: "InvalidInput", code: 400, userInfo: [NSLocalizedDescriptionKey: "Path and Document ID cannot be empty."])))
                return
            }
            guard let value = snapshot.value else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Document not found"])))
                return
            }
            
            do {
                let data = try JSONSerialization.data(withJSONObject: value)
                let object = try JSONDecoder().decode(T.self, from: data)
                completion(.success(object))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    /// Observes changes to a collection.
    /// - Parameters:
    ///   - path: The path of the collection to observe.
    ///   - completion: A closure that gets called with the result of the operation.
    func observeCollection<T: Codable>(path: String, as type: T.Type, completion: @escaping (Result<[T], Error>) -> Void) {
        db.child(path).observe(.value) { snapshot in
            guard !path.isEmpty else {
                completion(.failure(NSError(domain: "InvalidInput", code: 400, userInfo: [NSLocalizedDescriptionKey: "Path and Document ID cannot be empty."])))
                return
            }
            
            guard let value = snapshot.value as? [String: Any] else {
                completion(.success([]))
                return
            }
            
            do {
                let objects: [T] = try value.compactMap { _, objectData in
                    let data = try JSONSerialization.data(withJSONObject: objectData)
                    return try JSONDecoder().decode(T.self, from: data)
                }
                completion(.success(objects))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    /// Generic function to observe changes at a specific database path with an optional condition.
    /// - Parameters:
    ///   - path: The path in the database to observe.
    ///   - eventType: The type of event to observe (`.childAdded`, `.childChanged`, `.childRemoved`, etc.).
    ///   - condition: An optional tuple containing the key and value to filter the observations.
    ///   - completion: Completion handler with the observed data or an error.
    func observe<T: Codable>(at path: String, eventType: DataEventType, condition: (key: String, value: Any)? = nil, completion: @escaping (Result<T, Error>) -> Void) {
        guard !path.isEmpty else {
            completion(.failure(NSError(domain: "InvalidInput", code: 400, userInfo: [NSLocalizedDescriptionKey: "Path and Document ID cannot be empty."])))
            return
        }
        
        let ref = db.child(path)
        
        let query: DatabaseQuery
        if let condition = condition {
            query = ref.queryOrdered(byChild: condition.key).queryEqual(toValue: condition.value)
        } else {
            query = ref
        }
        
        query.observe(eventType) { snapshot in
            guard let data = snapshot.value else {
                let error = NSError(domain: "RealtimeDatabaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data found at path \(path)"])
                completion(.failure(error))
                return
            }
            
            do {
                // Decode the data into the generic type `T`
                let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                let decodedObject = try JSONDecoder().decode(T.self, from: jsonData)
                completion(.success(decodedObject))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
