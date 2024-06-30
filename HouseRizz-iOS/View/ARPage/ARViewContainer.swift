//
//  ARViewContainer.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 29/06/24.
//

import SwiftUI
import RealityKit
import ARKit

private let anchorNamePrefix = "model-"

struct ARViewContainer: UIViewRepresentable {
    @EnvironmentObject var placementSettings: PlacementSettingsViewModel
    @EnvironmentObject var sessionSettings: ARSessionSettingsViewModel
    @EnvironmentObject var sceneManager: SceneManager
    @EnvironmentObject var modelsViewModel: HR3DModelViewModel
    @EnvironmentObject var modelDeletionManager: ModelDeletionManager
    
    func makeUIView(context: Context) -> CustomARView {
        
        let arView = CustomARView(frame: .zero, sessionSettings: sessionSettings, modelDeletionManager: modelDeletionManager)
        
        arView.session.delegate = context.coordinator
        
        self.placementSettings.sceneObserver = arView.scene.subscribe(to: SceneEvents.Update.self, { (event) in
            self.updateScene(for: arView)
            self.updatePersistenceAvailability(for: arView)
            self.handlePersistence(for: arView)
        })

        return arView
        
    }
    
    func updateUIView(_ uiView: CustomARView, context: Context) {}
    
    private func updateScene( for arView: CustomARView) {
        
        arView.focusEntity?.isEnabled = self.placementSettings.selectedModel != nil
        
        if let modelAnchor = self.placementSettings.modelsConfirmedForPlacement.popLast(), let modelEntity = modelAnchor.model.modelEntity {
            if let anchor = modelAnchor.anchor {
                self.place(modelEntity, for: anchor, in: arView)
                arView.session.add(anchor: anchor)
                self.placementSettings.recentlyPlaced.append(modelAnchor.model)
            } else if let transform = getTransformForPlacement(in: arView) {
                let anchorName = anchorNamePrefix + modelAnchor.model.name
                let anchor = ARAnchor(name: anchorName, transform: transform)
                arView.session.add(anchor: anchor)
                self.placementSettings.recentlyPlaced.append(modelAnchor.model)
            }
        }
    }
    
    private func place(_ modelEntity: ModelEntity,for anchor: ARAnchor, in arView: ARView) {
        let clonedEntity = modelEntity.clone(recursive: true)
        
        clonedEntity.generateCollisionShapes(recursive: true)
        arView.installGestures([.translation, .rotation], for: clonedEntity)
        let anchorEntity = AnchorEntity(plane: .any)
        anchorEntity.addChild(clonedEntity)
        anchorEntity.anchoring = AnchoringComponent(anchor)
        arView.scene.addAnchor(anchorEntity)
        self.sceneManager.anchorEntities.append(anchorEntity)
    }
    
    private func getTransformForPlacement(in arView: ARView) -> simd_float4x4? {
        guard let query = arView.makeRaycastQuery(from: arView.center, allowing: .estimatedPlane, alignment: .any) else {
            return nil
        }
        
        guard let raycastResult = arView.session.raycast(query).first else { return nil }
        
        return raycastResult.worldTransform
    }
    
}

extension ARViewContainer {
    private func updatePersistenceAvailability(for arView: ARView) {
        guard let currentFrame = arView.session.currentFrame else {
            return
        }
        
        switch currentFrame.worldMappingStatus {
        case .mapped, .extending:
            self.sceneManager.isPersistanceAvailable = !self.sceneManager.anchorEntities.isEmpty
        default:
            self.sceneManager.isPersistanceAvailable = false
        }
    }
    
    private func handlePersistence(for arView: CustomARView) {
        if self.sceneManager.shouldSaveSceneToFilesystem {
            ScenePersistenceHelper.saveScene(for: arView, at: self.sceneManager.persistenceUrl)
        } else if self.sceneManager.shouldLoadSceneFromFilesystem {
            guard let scenePersistenceData = self.sceneManager.scenePersistenceData else {
                self.sceneManager.shouldLoadSceneFromFilesystem = false
                return
            }
            
            ScenePersistenceHelper.loadScene(for: arView, with: scenePersistenceData)
            
            self.sceneManager.anchorEntities.removeAll(keepingCapacity: true)
            
            self.sceneManager.shouldLoadSceneFromFilesystem = false
        }
    }
}

// MARK: - ARSessionDelagate + Coordinator

extension ARViewContainer {
    class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARViewContainer
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            for anchor in anchors {
                if let anchorName = anchor.name, anchorName.hasPrefix(anchorNamePrefix) {
                    let modelName = anchorName.dropFirst(anchorNamePrefix.count)
                    guard let model = self.parent.modelsViewModel.models.first(where: { $0.name == modelName}) else {
                        return
                    }
                    model.asyncLoadModelEntity { completed, error in
                        if completed {
                            let modelAnchor = ModelAnchor(model: model, anchor: anchor)
                            self.parent.placementSettings.modelsConfirmedForPlacement.append(modelAnchor)
                        }
                    }
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
}
