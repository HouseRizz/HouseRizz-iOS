//
//  ModelDeletionManager.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 30/06/24.
//

import SwiftUI
import RealityKit

class ModelDeletionManager: ObservableObject {
    @Published var entitySelectedForDeletion: ModelEntity? = nil {
        willSet(newValue) {
            if self.entitySelectedForDeletion == nil, let newlySelectedModelEntity = newValue {
                let component = ModelDebugOptionsComponent(visualizationMode: .lightingDiffuse)
                newlySelectedModelEntity.modelDebugOptions = component
            } else if let previouslySelectedModelEntity = self.entitySelectedForDeletion, let newlySelectedModelEntity = newValue {
                previouslySelectedModelEntity.modelDebugOptions = nil
                let component = ModelDebugOptionsComponent(visualizationMode: .lightingDiffuse)
                newlySelectedModelEntity.modelDebugOptions = component
            } else if newValue == nil {
                self.entitySelectedForDeletion?.modelDebugOptions = nil
            }
        }
    }
}
