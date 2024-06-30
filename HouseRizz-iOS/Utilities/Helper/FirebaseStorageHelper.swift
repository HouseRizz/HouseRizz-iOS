//
//  FirebaseStorageHelper.swift
//  arf
//
//  Created by Krish Mittal on 28/06/24.
//

import Foundation
import Firebase
import FirebaseStorage

class FirebaseStorageHelper {
    static private let cloudStorage = Storage.storage()
    
    class func asyncDownloadToFileSystem(relativePath: String, handler: @escaping (_ fileUrl: URL) -> Void) {
        let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileUrl = docsUrl.appendingPathComponent(relativePath)
        if FileManager.default.fileExists(atPath: fileUrl.path) {
            handler(fileUrl)
            return
        }
        let storageRef = cloudStorage.reference(withPath: relativePath)
        storageRef.write(toFile: fileUrl) { url, error in
            guard let localUrl = url else {
                return
            }
            
            handler(localUrl)
        }.resume()
    }
}
