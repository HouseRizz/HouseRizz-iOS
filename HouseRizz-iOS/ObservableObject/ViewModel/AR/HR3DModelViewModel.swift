//
//  HR3DModelViewModel.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 28/06/24.
//

import Foundation
import FirebaseFirestore

class HR3DModelViewModel: ObservableObject {
    @Published var models: [HR3DModel] = []
    
    private let db = Firestore.firestore()
    
    func fetchData(){
        db.collection("models").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                return
            }
            self.models = documents.map {(queryDocumentSnapshot) -> HR3DModel in
                let data = queryDocumentSnapshot.data()
                let name = data["name"] as? String ?? ""
                let categoryText = data["category"] as? String ?? ""
                let category = ModelCategory(rawValue: categoryText) ?? .decor
                let scaleCompensation = data["scaleCompensation"] as? Double ?? 1.0
                return HR3DModel(name: name, category: category, scaleCompensation: Float(scaleCompensation))
            }
        }
    }
}
