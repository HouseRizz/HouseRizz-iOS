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
}
