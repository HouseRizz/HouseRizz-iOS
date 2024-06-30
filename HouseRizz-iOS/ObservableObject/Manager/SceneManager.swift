//
//  SceneManager.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 29/06/24.
//

import SwiftUI
import RealityKit

class SceneManager: ObservableObject {
    @Published var isPersistanceAvailable: Bool = false
    @Published var anchorEntities: [AnchorEntity] = []
    
    lazy var persistenceUrl: URL = {
        do {
            return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("hr.persistence")
        } catch {
            fatalError(error.localizedDescription)
        }
    }()
    
    var scenePersistenceData: Data? {
        return try? Data(contentsOf: persistenceUrl)
    }
}
