//
//  CameraView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 04/04/24.
//

import SwiftUI

struct CameraView: View {
    @EnvironmentObject var placementSettigns: PlacementSettingsViewModel
    @EnvironmentObject var modelsViewModel: HR3DModelViewModel
    @EnvironmentObject var modelDeletionManager: ModelDeletionManager
    @State private var isControlsVisible: Bool = false
    @State private var showBrowse: Bool = false
    @State private var showSettings: Bool = false
    @State private var selectedControlModel: Int = 0
    
    var body: some View {
        ZStack {
            ARViewContainer()
            
            if self.placementSettigns.selectedModel != nil {
                PlacementView()
            } else if self.modelDeletionManager.entitySelectedForDeletion != nil {
                DeletionView()
            } else {
                ControlView(isControlsVisible: $isControlsVisible, showBrowse: $showBrowse, showSettings: $showSettings, selectedControlModel: $selectedControlModel)

            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear() {
            self.modelsViewModel.fetchData()
        }
    }
}

