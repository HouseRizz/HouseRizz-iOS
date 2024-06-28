//
//  CameraView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 04/04/24.
//

import SwiftUI
import RealityKit

struct CameraView: View {
    @EnvironmentObject var placementSettigns: PlacementSettingsViewModel
    @State private var isControlsVisible: Bool = false
    @State private var showBrowse: Bool = false
    @State private var showSettings: Bool = false
    
    var body: some View {
        ZStack {
            ARViewContainer()
            
            if self.placementSettigns.selectedModel == nil {
                ControlView(isControlsVisible: $isControlsVisible, showBrowse: $showBrowse, showSettings: $showSettings)
            } else {
                PlacementView()
            }
            
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    @EnvironmentObject var placementSettings: PlacementSettingsViewModel
    @EnvironmentObject var sessionSettings: ARSessionSettingsViewModel
    
    func makeUIView(context: Context) -> CustomARView {
        
        let arView = CustomARView(frame: .zero, sessionSettings: sessionSettings)
        
        self.placementSettings.sceneObserver = arView.scene.subscribe(to: SceneEvents.Update.self, { (event) in
            self.updateScene(for: arView)
        })

        return arView
        
    }
    
    func updateUIView(_ uiView: CustomARView, context: Context) {}
    
    private func updateScene( for arView: CustomARView) {
        
        arView.focusEntity?.isEnabled = self.placementSettings.selectedModel != nil
        
        if let confirmedModel = self.placementSettings.confirmedModel, let modelEntity = confirmedModel.modelEntity {
            self.place(modelEntity, in: arView)
            self.placementSettings.confirmedModel = nil
        }
    }
    
    private func place(_ modelEntity: ModelEntity, in arView: ARView) {
        let clonedEntity = modelEntity.clone(recursive: true)
        
        clonedEntity.generateCollisionShapes(recursive: true)
        arView.installGestures([.translation, .rotation], for: clonedEntity)
        let anchorEntity = AnchorEntity(plane: .any)
        anchorEntity.addChild(clonedEntity)
        arView.scene.addAnchor(anchorEntity)
    }
    
}

