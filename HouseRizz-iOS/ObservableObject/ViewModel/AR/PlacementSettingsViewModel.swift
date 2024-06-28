//
//  PlacementSettingsViewModel.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 28/06/24.
//

import SwiftUI
import RealityKit
import Combine

class PlacementSettingsViewModel: ObservableObject {
    static let shared = PlacementSettingsViewModel()
    
    // when user slects model in placementview
    @Published var selectedModel: HR3DModel? {
        willSet(newValue) {
            print("\(newValue?.name ?? "")")
        }
    }
    
    // confitm in placement
    @Published var confirmedModel: HR3DModel? {
        willSet(newValue) {
            guard let model = newValue else {
                return
            }
            
            print(model.name)
            
            self.recentlyPlaced.append(model)
        }
    }
    
    @Published var recentlyPlaced: [HR3DModel] = []
    
    var sceneObserver: Cancellable?
}
