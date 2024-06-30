//
//  PlacementSettingsViewModel.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 28/06/24.
//

import SwiftUI
import RealityKit
import Combine
import ARKit

struct ModelAnchor {
    var model: HR3DModel
    var anchor: ARAnchor?
}

class PlacementSettingsViewModel: ObservableObject {
    static let shared = PlacementSettingsViewModel()
    
    // when user slects model in placementview
    @Published var selectedModel: HR3DModel? {
        willSet(newValue) {
            print("\(newValue?.name ?? "")")
        }
    }
    
    @Published var recentlyPlaced: [HR3DModel] = []
    
    var modelsConfirmedForPlacement: [ModelAnchor] = []
    
    var sceneObserver: Cancellable?
}
