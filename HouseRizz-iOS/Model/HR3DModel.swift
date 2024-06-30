//
//  HR3DModel.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 28/06/24.
//

import SwiftUI
import RealityKit
import Combine

enum ModelCategory: String, CaseIterable {
    case table
    case chair
    case decor
    case light
    
    var label: String {
        get {
            switch self {
                
            case .table:
                return "Tables"
            case .chair:
                return "Chairs"
            case .decor:
                return "Decors"
            case .light:
                return "Lights"
            }
        }
    }
}

class HR3DModel: ObservableObject, Identifiable {
    var id:String = UUID().uuidString
    var name: String
    var category: ModelCategory
    @Published var thumbnail: UIImage
    var modelEntity: ModelEntity?
    var scaleCompensation: Float
    
    private var cancellable: AnyCancellable?
    
    init(name: String, category: ModelCategory, scaleCompensation: Float = 1.0) {
        self.name = name
        self.category = category
        self.thumbnail = UIImage(systemName: "photo")!
        self.scaleCompensation = scaleCompensation
        
        FirebaseStorageHelper.asyncDownloadToFileSystem(relativePath: "thumbnails/\(self.name).png") { fileUrl in
            do {
                let imageData = try Data(contentsOf: fileUrl)
                self.thumbnail = UIImage(data: imageData) ?? self.thumbnail
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func asyncLoadModelEntity(handler: @escaping (_ completed: Bool, _ error: Error?) -> Void) {
        FirebaseStorageHelper.asyncDownloadToFileSystem(relativePath: "models/\(self.name).usdz") { fileUrl in
            self.cancellable = ModelEntity.loadModelAsync(contentsOf: fileUrl)
                .sink(receiveCompletion: { loadCompletion in
                    switch loadCompletion {
                    case .finished:
                        break
                    case .failure(let error):
                        print(error.localizedDescription)
                        handler(false, error)
                    }
                }, receiveValue: { modelEntity in
                    self.modelEntity = modelEntity
                    self.modelEntity?.scale *= self.scaleCompensation
                    handler(true, nil)
                })
        }
        
    }
}
