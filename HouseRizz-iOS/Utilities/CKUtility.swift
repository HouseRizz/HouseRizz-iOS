//  CKUtility.swift
//  Created by Krish Mittal.

import Foundation
import CloudKit
import Combine

protocol CKitableProtocol {
    init?(record: CKRecord)
    var record: CKRecord {get}
}

class CKUtility {
    
    enum CloudKitError: LocalizedError {
        case iCloudAccountNotFound
        case iCloudAccountNotDetermined
        case iCloudAccountUnknown
        case iCloudAccountRestricted
        case iCloudPermissionNotGranted
        case iCloudCouldNotFetchUserRecordID
        case iCloudCouldNotDiscoverUser
    }
}

// MARK: USER FUNCTIONS

extension CKUtility {
    static private func getiCloudStatus(completion: @escaping (Result<Bool, Error>)->()){
        CKContainer.default().accountStatus { returnedStatus, returnedError in
            switch returnedStatus {
            case .available:
                completion(.success(true))
            case .noAccount:
                completion(.failure(CloudKitError.iCloudAccountNotFound))
            case .couldNotDetermine:
                completion(.failure(CloudKitError.iCloudAccountNotDetermined))
            case .restricted:
                completion(.failure(CloudKitError.iCloudAccountRestricted))
            case .temporarilyUnavailable:
                completion(.failure(CloudKitError.iCloudAccountNotFound))
            default:
                completion(.failure(CloudKitError.iCloudAccountUnknown))
            }
        }
    }
    
    static func getiCloudStatus() -> Future<Bool,Error>{
        Future { promise in
            CKUtility.getiCloudStatus { result in
                promise(result)
            }
        }
    }
    
    static private func requestApplicationPermission(completion: @escaping (Result<Bool, Error>)->()) {
        CKContainer.default().requestApplicationPermission([.userDiscoverability]){ returnedStatus, returnedError in
            if returnedStatus == .granted {
                completion(.success(true))
            } else {
                completion(.failure(CloudKitError.iCloudPermissionNotGranted))
            }
            
        }
    }
    
    static func requestApplicationPermission() -> Future<Bool,Error> {
        Future { promise in
            CKUtility.requestApplicationPermission { result in
                promise(result)
            }
        }
    }
    
    static func fetchUserRecordID(completion: @escaping (Result<CKRecord.ID, Error>)->()) {
        CKContainer.default().fetchUserRecordID { returnedID, returnedError in
            if let id = returnedID {
                completion(.success(id))
            } else {
                completion(.failure(CloudKitError.iCloudCouldNotFetchUserRecordID))
            }
        }
    }
    
    static private func discoverUserIdentity(id: CKRecord.ID,completion: @escaping (Result<String, Error>)->()) {
        CKContainer.default().discoverUserIdentity(withUserRecordID: id) { returnedIdentity, returnedError in
            if let name = returnedIdentity?.nameComponents?.givenName {
                completion(.success(name))
            } else {
                completion(.failure(CloudKitError.iCloudCouldNotDiscoverUser))
            }
        }
    }
    
    static private func discoverUserIdentity(completion: @escaping (Result<String, Error>)->()) {
        fetchUserRecordID { fetchCompletion in
            switch fetchCompletion {
            case .success(let recordID):
                CKUtility.discoverUserIdentity(id: recordID, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    static func discoverUserIdentity() -> Future<String,Error> {
        Future { promise in
            CKUtility.discoverUserIdentity { result in
                promise(result)
            }
        }
    }
}

// MARK: CRUD FUNCTIONS

extension CKUtility {
    
    static func fetch<T:CKitableProtocol>(predicate: NSPredicate,
                      recordType: CKRecord.RecordType,
                      sortDescription: [NSSortDescriptor]? = nil,
                      resultsLimit: Int? = nil) -> Future<[T], Error> {
        Future { promise in
            CKUtility.fetch(predicate: predicate,
                            recordType: recordType,
                            sortDescription: sortDescription,
                            resultsLimit:resultsLimit) { (item: [T]) in
                promise(.success(item))
            }
        }
    }
    
    static private func fetch<T:CKitableProtocol>(predicate: NSPredicate,
                      recordType: CKRecord.RecordType,
                      sortDescription: [NSSortDescriptor]? = nil,
                      resultsLimit: Int? = nil,
                      completion: @escaping (_ item: [T]) -> ()
    ) {
        
        let operation = createOperation(predicate: predicate, recordType: recordType, sortDescription: sortDescription, resultsLimit: resultsLimit)
        
        var returnedItems: [T] = []
        addRecordMatchedBlock(operation: operation) { item in
            returnedItems.append(item)
        }
        
        addQueryResultBlock(operation: operation) { finished in
            completion(returnedItems)
        }
        
        // Execute Operation
        add(operation: operation)
    }
    
    static private func createOperation(predicate: NSPredicate,
                                        recordType: CKRecord.RecordType,
                                        sortDescription: [NSSortDescriptor]? = nil,
                                        resultsLimit: Int? = nil) -> CKQueryOperation {
        
        let query = CKQuery(recordType: recordType, predicate: predicate)
        query.sortDescriptors = sortDescription
        let queryOperation = CKQueryOperation(query: query)
        if let limit = resultsLimit {
            queryOperation.resultsLimit = limit
        }
        return queryOperation
    }
    
    static private func addRecordMatchedBlock<T: CKitableProtocol>(operation: CKQueryOperation, completion: @escaping (_ item: T) -> ()) {
        if #available(iOS 15.0, *) {
            operation.recordMatchedBlock = { returnedRedcordID, returnedResults in
                switch returnedResults {
                case .success(let record):
                    guard let item = T(record: record) else {return}
                    completion(item)
                case .failure:
                    break
                }
            }
        } else {
            operation.recordFetchedBlock = { returnedRecord in
                guard let item = T(record: returnedRecord) else {return}
                completion(item)
            }
        }
    }
    
    static private func addQueryResultBlock(operation: CKQueryOperation, completion: @escaping (_ finished: Bool) -> ()) {
        if #available(iOS 15.0, *) {
            operation.queryResultBlock = { returnedResult in
                completion(true)
            }
        } else {
            operation.queryCompletionBlock = { returnedCursor, returnedError in
                completion(true)
            }
        }
    }
    
    static private func add(operation:CKDatabaseOperation) {
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    static func add<T: CKitableProtocol>(item: T, completion: @escaping (Result<Bool,Error>) -> ()) {
        
        // Get record
        let record = item.record
        
        // Save to CK
        save(record: record, completion: completion)
    }
    
    static func update<T: CKitableProtocol>(item: T, completion: @escaping (Result<Bool,Error>) -> ()) {
        add(item: item, completion: completion)
    }
    
    static private func save(record: CKRecord, completion: @escaping (Result<Bool,Error>) -> ()){
        CKContainer.default().publicCloudDatabase.save(record) { returnedRecord, returnedError in
            if let error = returnedError {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
    static func delete<T: CKitableProtocol>(item: T) -> Future<Bool, Error> {
        Future { promise in
            CKUtility.delete(item: item, completion: promise)
        }
    }
    
    static private func delete<T: CKitableProtocol>(item: T, completion: @escaping (Result<Bool,Error>) -> ()) {
        CKUtility.delete(record: item.record, completion: completion)
    }
    
    static private func delete(record: CKRecord, completion: @escaping (Result<Bool,Error>) -> ()) {
        CKContainer.default().publicCloudDatabase.delete(withRecordID: record.recordID) { retunedRecordID, retunedError in
            if let error = retunedError {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
}
