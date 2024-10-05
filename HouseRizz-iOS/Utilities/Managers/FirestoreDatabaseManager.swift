//  FirestoreDatabaseManager.swift
//  Created by Krish Mittal.

import Foundation
import Firebase
import FirebaseFirestore

/// A manager class for handling Firestore database operations.
class FirestoreDatabaseManager {
    /// Shared instance of the FirestoreDatabaseManager.
    static let shared = FirestoreDatabaseManager()
    
    private let db: Firestore
    
    private init() { db = Firestore.firestore() }
}

// MARK: - The Generic CRUD use this with asObject and asDictionary in Models

extension FirestoreDatabaseManager {
    /// Reads a document from the specified collection and returns the raw data.
    /// - Parameters:
    ///   - collectionPath: The path of the collection containing the document.
    ///   - documentId: The ID of the document to read.
    ///   - completion: A closure that gets called with the result of the operation.
    func readDocument(collectionPath: String, documentId: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard !collectionPath.isEmpty, !documentId.isEmpty else {
            completion(.failure(NSError(domain: "InvalidInput", code: 400, userInfo: [NSLocalizedDescriptionKey: "Path and Document ID cannot be empty."])))
            return
        }
        
        Firestore.firestore().collection(collectionPath).document(documentId).getDocument { (document, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = document?.data() else {
                let error = NSError(domain: "FirestoreDatabaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data found"])
                completion(.failure(error))
                return
            }
            
            completion(.success(data))
        }
    }
    
    func queryDocuments(collectionPath: String, field: String, isIn values: [Any], completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
        db.collection(collectionPath).whereField(field, in: values).getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                completion(.success([]))
                return
            }
            
            let data = documents.map { $0.data() }
            completion(.success(data))
        }
    }
    
    /// Queries documents in a collection based on a field value and returns the raw data.
    /// - Parameters:
    ///   - collectionPath: The path of the collection to query.
    ///   - field: The field to query by.
    ///   - value: The value to match for the field.
    ///   - completion: A closure that gets called with the result of the operation.
    func queryDocuments(collectionPath: String, field: String, isEqualTo value: Any, completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
        guard !collectionPath.isEmpty else {
            completion(.failure(NSError(domain: "InvalidInput", code: 400, userInfo: [NSLocalizedDescriptionKey: "Path and Document ID cannot be empty."])))
            return
        }
        
        if let valuee = value as? String, valuee == "" {
            db.collection(collectionPath).getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                let data = documents.map { $0.data() }
                completion(.success(data))
            }
        }
        else {
            db.collection(collectionPath).whereField(field, isEqualTo: value).getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                let data = documents.map { $0.data() }
                completion(.success(data))
            }
        }
    }
    
    func queryDocuments(collectionPath: String, filters: [(field: String, isEqualTo: Any)], completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
        guard !collectionPath.isEmpty else {
            completion(.failure(NSError(domain: "InvalidInput", code: 400, userInfo: [NSLocalizedDescriptionKey: "Path cannot be empty."])))
            return
        }
        
        var query: Query = db.collection(collectionPath)
        
        for filter in filters { query = query.whereField(filter.field, isEqualTo: filter.isEqualTo) }
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                completion(.success([]))
                return
            }
            
            let data = documents.map { $0.data() }
            completion(.success(data))
        }
    }
    
    func queryDocumentsSnapshot(collectionPath: String, field: String, isEqualTo value: Any, completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
        guard !collectionPath.isEmpty else {
            completion(.failure(NSError(domain: "InvalidInput", code: 400, userInfo: [NSLocalizedDescriptionKey: "Path and Document ID cannot be empty."])))
            return
        }
        
        db.collection(collectionPath).whereField(field, isEqualTo: value).addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                completion(.success([]))
                return
            }
            
            let data = documents.map { $0.data() }
            completion(.success(data))
        }
    }
    
    /// Queries documents in a collection based on an array field containing a specific value.
    /// - Parameters:
    ///   - collectionPath: The path of the collection to query.
    ///   - field: The array field to query by.
    ///   - value: The value to check for in the array field.
    ///   - completion: A closure that gets called with the result of the operation.
    func queryDocuments(collectionPath: String, field: String, arrayContains value: Any, completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
        guard !collectionPath.isEmpty else {
            completion(.failure(NSError(domain: "InvalidInput", code: 400, userInfo: [NSLocalizedDescriptionKey: "Path and Document ID cannot be empty."])))
            return
        }
        
        db.collection(collectionPath).whereField(field, arrayContains: value).getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                completion(.success([]))
                return
            }
            
            let data = documents.map { $0.data() }
            completion(.success(data))
        }
    }
    
    /// Updates a document in the specified collection with raw data.
    /// - Parameters:
    ///   - collectionPath: The path of the collection containing the document.
    ///   - documentId: The ID of the document to update.
    ///   - data: The new data to update the document with.
    ///   - completion: A closure that gets called with the result of the operation.
    func updateDocument(collectionPath: String, documentId: String, data: [String: Any], completion: @escaping (Result<String, Error>) -> Void) {
        guard !collectionPath.isEmpty, !documentId.isEmpty else {
            completion(.failure(NSError(domain: "InvalidInput", code: 400, userInfo: [NSLocalizedDescriptionKey: "Path and Document ID cannot be empty."])))
            return
        }
        
        if documentId == "" { return }
        db.collection(collectionPath).document(documentId).updateData(data) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success((documentId)))
            }
        }
    }
    
    /// Creates a new document in the specified collection with a UUID as the document ID.
    /// - Parameters:
    ///   - collectionPath: The path of the collection to add the document to.
    ///   - data: The data to be stored in the new document.
    ///   - completion: A closure that gets called with the result of the operation.
    /// - Generate a UUID for the document ID using UUID().uuidString. Example A3D9B6F0-2F7D-4F0D-8A6F-53B1AE72C416
    func postDocument(collectionPath: String, data: [String: Any], completion: @escaping (Result<String, Error>) -> Void) {
        guard !collectionPath.isEmpty else {
            completion(.failure(NSError(domain: "InvalidInput", code: 400, userInfo: [NSLocalizedDescriptionKey: "Path and Document ID cannot be empty."])))
            return
        }
        
        let documentId = UUID().uuidString
        db.collection(collectionPath).document(documentId).setData(data) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(documentId))
            }
        }
    }
    
    /*
    /// This Function Uses the Firebase UID Format. Example - v0oxIqwlVxYzwOfhh6Go
    /// Creates a new document in the specified collection with raw data.
    /// - Parameters:
    ///   - collectionPath: The path of the collection to add the document to.
    ///   - data: The data to be stored in the new document.
    ///   - completion: A closure that gets called with the result of the operation.
    func postDocument(collectionPath: String, data: [String: Any], completion: @escaping (Result<String, Error>) -> Void) {
        var ref: DocumentReference? = nil
        ref = db.collection(collectionPath).addDocument(data: data) { error in
            if let error = error {
                completion(.failure(error))
            } else if let documentId = ref?.documentID {
                completion(.success(documentId))
            } else {
                let error = NSError(domain: "FirestoreDatabaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get document ID"])
                completion(.failure(error))
            }
        }
    }
     */
    
    /// Query a document by a specific field and update it.
    /// - Parameters:
    ///   - collectionPath: The path of the Firestore collection.
    ///   - field: The field to query by (e.g., "messageId").
    ///   - value: The value to match for the field.
    ///   - data: The data to update in the matching document(s).
    ///   - completion: A closure that gets called with the result of the operation.
    func queryAndUpdateDocument(
        collectionPath: String,
        field: String,
        isEqualTo value: Any,
        data: [String: Any],
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard !collectionPath.isEmpty else {
            completion(.failure(NSError(domain: "InvalidInput", code: 400, userInfo: [NSLocalizedDescriptionKey: "Path and Document ID cannot be empty."])))
            return
        }
        
        db.collection(collectionPath).whereField(field, isEqualTo: value).getDocuments { querySnapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = querySnapshot?.documents.first else {
                let error = NSError(domain: "FirestoreDatabaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No document found with the specified field value"])
                completion(.failure(error))
                return
            }
            
            let documentId = document.documentID
            self.db.collection(collectionPath).document(documentId).updateData(data) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    /// Gets a reference to a specific document.
    /// - Parameters:
    ///   - collectionPath: The path of the collection containing the document.
    ///   - documentId: The ID of the document.
    /// - Returns: A `DocumentReference` for the specified document.
    func getDocumentReference(collectionPath: String, documentId: String) -> DocumentReference {
        if collectionPath.isEmpty || documentId.isEmpty { fatalError("Empty document path or ID") }
        return db.collection(collectionPath).document(documentId)
    }
}

// MARK: - Listener Extension

extension FirestoreDatabaseManager {
    /// Adds a snapshot listener to a specific document.
    /// - Parameters:
    ///   - collectionPath: The path of the collection containing the document.
    ///   - documentId: The ID of the document to listen to.
    ///   - completion: A closure that gets called with the document snapshot or error.
    /// - Returns: A `ListenerRegistration` that can be used to remove the listener.
    func addSnapshotListener(collectionPath: String, documentId: String, completion: @escaping (DocumentSnapshot?, Error?) -> Void) -> ListenerRegistration {
        guard !collectionPath.isEmpty, !documentId.isEmpty else { fatalError("Empty document path or ID") }
        let documentReference = db.collection(collectionPath).document(documentId)
        return documentReference.addSnapshotListener { (documentSnapshot, error) in
            completion(documentSnapshot, error)
        }
    }
    
    /// Adds a snapshot listener to a collection.
    /// - Parameters:
    ///   - collectionPath: The path of the collection to listen to.
    ///   - completion: A closure that gets called whenever the collection changes.
    ///     The closure takes two parameters:
    ///     - querySnapshot: A `QuerySnapshot` object containing the current state of the collection.
    ///       It's `nil` if there was an error.
    ///     - error: An `Error` object that describes the error that occurred, or `nil` if there was no error.
    /// - Returns: A `ListenerRegistration` object that can be used to remove the listener when it's no longer needed.
    /// - Note: This listener will be triggered immediately with the initial data and again whenever the collection changes.
    func addCollectionSnapshotListener(collectionPath: String, completion: @escaping (QuerySnapshot?, Error?) -> Void) -> ListenerRegistration {
        guard !collectionPath.isEmpty else { fatalError("Empty document path or ID") }
        let collectionReference = db.collection(collectionPath)
        return collectionReference.addSnapshotListener { (querySnapshot, error) in
            completion(querySnapshot, error)
        }
    }
}

// MARK: - Generic CRUD Operations - JSON Serialization + Encoder
extension FirestoreDatabaseManager {
    
    /// Creates a new document in the specified collection with a UUID as the document ID.
    /// - Parameters:
    ///   - collectionPath: The path of the collection to add the document to.
    ///   - data: The data to be stored in the new document.
    ///   - completion: A closure that gets called with the result of the operation.
    /// - Generate a UUID for the document ID using UUID().uuidString. Example A3D9B6F0-2F7D-4F0D-8A6F-53B1AE72C416
    func create<T: Codable>(collectionPath: String, data: T, completion: @escaping (Result<String, Error>) -> Void) {
        guard !collectionPath.isEmpty else {
            completion(.failure(NSError(domain: "InvalidInput", code: 400, userInfo: [NSLocalizedDescriptionKey: "Path and Document ID cannot be empty."])))
            return
        }
        
        do {
            let encodedData = try JSONEncoder().encode(data)
            let dictionary = try JSONSerialization.jsonObject(with: encodedData, options: .allowFragments) as? [String: Any] ?? [:]
            
            let documentId = UUID().uuidString // Generate a UUID for the document ID
            db.collection(collectionPath).document(documentId).setData(dictionary) { error in
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
    
    /*
    /// Creates a new document in the specified collection.
    /// - Parameters:
    ///   - collectionPath: The path of the collection to add the document to.
    ///   - data: The data to be stored in the new document.
    ///   - completion: A closure that gets called with the result of the operation.
    func create<T: Codable>(collectionPath: String, data: T, completion: @escaping (Result<String, Error>) -> Void) {
        do {
            let encodedData = try JSONEncoder().encode(data)
            let dictionary = try JSONSerialization.jsonObject(with: encodedData, options: .allowFragments) as? [String: Any] ?? [:]
            
            var ref: DocumentReference? = nil
            ref = db.collection(collectionPath).addDocument(data: dictionary) { error in
                if let error = error {
                    completion(.failure(error))
                } else if let documentId = ref?.documentID {
                    completion(.success(documentId))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    */
    
    /// Reads a document from the specified collection.
    /// - Parameters:
    ///   - collectionPath: The path of the collection containing the document.
    ///   - documentId: The ID of the document to read.
    ///   - type: The type to decode the document data into.
    ///   - completion: A closure that gets called with the result of the operation.
    func read<T: Codable>(collectionPath: String, documentId: String, as type: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        guard !collectionPath.isEmpty, !documentId.isEmpty else {
            completion(.failure(NSError(domain: "InvalidInput", code: 400, userInfo: [NSLocalizedDescriptionKey: "Path and Document ID cannot be empty."])))
            return
        }
        
        db.collection(collectionPath).document(documentId).getDocument { (document, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = document?.data() else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Document not found"])))
                return
            }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                let decodedObject = try JSONDecoder().decode(T.self, from: jsonData)
                completion(.success(decodedObject))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    /// Updates a document in the specified collection.
    /// - Parameters:
    ///   - collectionPath: The path of the collection containing the document.
    ///   - documentId: The ID of the document to update.
    ///   - data: The new data to update the document with.
    ///   - completion: A closure that gets called with the result of the operation.
    func update<T: Codable>(collectionPath: String, documentId: String, data: T, completion: @escaping (Result<Void, Error>) -> Void) {
        guard !collectionPath.isEmpty, !documentId.isEmpty else {
            completion(.failure(NSError(domain: "InvalidInput", code: 400, userInfo: [NSLocalizedDescriptionKey: "Path and Document ID cannot be empty."])))
            return
        }
        
        do {
            let encodedData = try JSONEncoder().encode(data)
            let dictionary = try JSONSerialization.jsonObject(with: encodedData, options: .allowFragments) as? [String: Any] ?? [:]
            
            db.collection(collectionPath).document(documentId).updateData(dictionary) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    /// Deletes a document from the specified collection.
    /// - Parameters:
    ///   - collectionPath: The path of the collection containing the document.
    ///   - documentId: The ID of the document to delete.
    ///   - completion: A closure that gets called with the result of the operation.
    func delete(collectionPath: String, documentId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard !collectionPath.isEmpty, !documentId.isEmpty else {
            completion(.failure(NSError(domain: "InvalidInput", code: 400, userInfo: [NSLocalizedDescriptionKey: "Path and Document ID cannot be empty."])))
            return
        }
        
        db.collection(collectionPath).document(documentId).delete() { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    /// Queries documents in a collection based on a field value.
    /// - Parameters:
    ///   - collectionPath: The path of the collection to query.
    ///   - field: The field to query by.
    ///   - value: The value to match for the field.
    ///   - type: The type to decode the document data into.
    ///   - completion: A closure that gets called with the result of the operation.
    func query<T: Codable>(collectionPath: String, field: String, isEqualTo value: Any, as type: T.Type, completion: @escaping (Result<[T], Error>) -> Void) {
        guard !collectionPath.isEmpty else {
            completion(.failure(NSError(domain: "InvalidInput", code: 400, userInfo: [NSLocalizedDescriptionKey: "Path and Document ID cannot be empty."])))
            return
        }
        
        db.collection(collectionPath).whereField(field, isEqualTo: value).getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                completion(.success([]))
                return
            }
            
            do {
                let decodedObjects: [T] = try documents.compactMap { document in
                    let jsonData = try JSONSerialization.data(withJSONObject: document.data(), options: [])
                    return try JSONDecoder().decode(T.self, from: jsonData)
                }
                completion(.success(decodedObjects))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func queryDocumentsAlways(collectionPath: String, field: String, isEqualTo value: Any, completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
        guard !collectionPath.isEmpty else {
            completion(.failure(NSError(domain: "InvalidInput", code: 400, userInfo: [NSLocalizedDescriptionKey: "Path and Document ID cannot be empty."])))
            return
        }
        
        db.collection(collectionPath).whereField(field, isEqualTo: value).addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let snapshot = querySnapshot else {
                completion(.success([]))
                return
            }
            
            if snapshot.metadata.hasPendingWrites || snapshot.metadata.isFromCache {
                // Ignore metadata changes
                return
            }
            
            snapshot.documentChanges.forEach { diff in
                if (diff.type == .added) {
                    print("Conversation Added")
                    let documents = snapshot.documents.map({ $0.data() })
                    completion(.success(documents))

                }
                if (diff.type == .modified) {
                    print("Conversation Modified")
                            let documents = snapshot.documents.map({ $0.data() })
                            completion(.success(documents))

                }
                    
                if (diff.type == .removed) {
                    print("Conversation Removed")
                    

                }
            }
        }
    }
    
    /// Adds a listener to a specific document.
    /// - Parameters:
    ///   - collectionPath: The path of the collection containing the document.
    ///   - documentId: The ID of the document to listen to.
    ///   - type: The type to decode the document data into.
    ///   - completion: A closure that gets called with the result of the operation.
    /// - Returns: A `ListenerRegistration` that can be used to remove the listener.
    func addListener<T: Codable>(collectionPath: String, documentId: String, as type: T.Type, completion: @escaping (Result<T, Error>) -> Void) -> ListenerRegistration {
        if collectionPath.isEmpty || documentId.isEmpty { fatalError("Empty document path or ID") }
        
        return db.collection(collectionPath).document(documentId).addSnapshotListener { (documentSnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = documentSnapshot?.data() else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Document not found"])))
                return
            }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                let decodedObject = try JSONDecoder().decode(T.self, from: jsonData)
                completion(.success(decodedObject))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
}

// MARK: - To be Tested

extension FirestoreDatabaseManager {
    /// Fetches all documents in a collection
    /// - Parameters:
    ///   - collectionPath: The path of the collection to fetch from
    ///   - completion: A closure that gets called with the result of the operation
    func fetchAllDocuments(collectionPath: String, completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
        guard !collectionPath.isEmpty else {
            completion(.failure(NSError(domain: "InvalidInput", code: 400, userInfo: [NSLocalizedDescriptionKey: "Path and Document ID cannot be empty."])))
            return
        }
        
        db.collection(collectionPath).getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let documents = querySnapshot?.documents.map { $0.data() } ?? []
            completion(.success(documents))
        }
    }
    
    /// Performs a compound query with multiple conditions
    /// - Parameters:
    ///   - collectionPath: The path of the collection to query
    ///   - conditions: An array of tuples representing the conditions (field, operator, value)
    ///   - completion: A closure that gets called with the result of the operation
    func compoundQuery(collectionPath: String, conditions: [(String, FirestoreFilterOperator, Any)], completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
        guard !collectionPath.isEmpty else {
            completion(.failure(NSError(domain: "InvalidInput", code: 400, userInfo: [NSLocalizedDescriptionKey: "Path and Document ID cannot be empty."])))
            return
        }
        
        var query: Query = db.collection(collectionPath)
        
        for (field, operatorType, value) in conditions {
            switch operatorType {
            case .isEqualTo:
                query = query.whereField(field, isEqualTo: value)
            case .isGreaterThan:
                query = query.whereField(field, isGreaterThan: value)
            case .isLessThan:
                query = query.whereField(field, isLessThan: value)
                // Add more cases for other operators as needed
            }
        }
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let documents = querySnapshot?.documents.map { $0.data() } ?? []
            completion(.success(documents))
        }
    }
    
    /// Performs a transaction that reads and writes data
    /// - Parameter updateBlock: A closure that performs the transaction operations
    /// - Returns: A result indicating success or failure of the transaction
    @discardableResult
    func performTransaction(_ updateBlock: @escaping (Transaction) -> Any?) async throws -> Any? {
        return try await db.runTransaction({ (transaction, errorPointer) -> Any? in
            return updateBlock(transaction)
        })
    }
    
    /// Adds a document with a custom ID
    /// - Parameters:
    ///   - collectionPath: The path of the collection to add the document to
    ///   - documentId: The custom ID for the new document
    ///   - data: The data to be stored in the new document
    ///   - completion: A closure that gets called with the result of the operation
    func addDocumentWithCustomId(collectionPath: String, documentId: String, data: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        guard !collectionPath.isEmpty, !documentId.isEmpty else {
            completion(.failure(NSError(domain: "InvalidInput", code: 400, userInfo: [NSLocalizedDescriptionKey: "Path and Document ID cannot be empty."])))
            return
        }
        
        db.collection(collectionPath).document(documentId).setData(data) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}

enum FirestoreFilterOperator {
    case isEqualTo
    case isGreaterThan
    case isLessThan
}
