//
//  ControlView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 28/06/24.
//

import SwiftUI

enum ControlModes: String, CaseIterable {
    case browse, scene
}

struct ControlView: View {
    @Binding var isControlsVisible: Bool
    @Binding var showBrowse: Bool
    @Binding var showSettings: Bool
    @Binding var selectedControlModel: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if isControlsVisible {
                HStack {
                    ControlModePicker(selectedControlModel: $selectedControlModel)
                    Spacer()
                }
            } else {
                Color.clear.frame(height: 30)
            }
            
            HStack {
                if isControlsVisible {
                    ControlButtonBar(showBrowse: $showBrowse, showSettings: $showSettings, selectedControlMode: selectedControlModel)
                }
                Spacer()
                ControlVisibilityToggleButton(isControlsVisible: $isControlsVisible)
            }
            
            Spacer()
        }
        .padding(.top, 45)
        .padding(.horizontal, 20)
    }
}

struct ControlVisibilityToggleButton: View {
    @Binding var isControlsVisible: Bool
    var body: some View {
        HStack {
            Spacer()
            
            Button(action: {
                self.isControlsVisible.toggle()
            }) {
                Image(systemName: self.isControlsVisible ? "rectangle" : "slider.horizontal.below.rectangle")
                    .font(.system(size: 35))
                    .foregroundStyle(.white)
                    .buttonStyle(PlainButtonStyle())
            }
            .frame(width: 50, height: 50)
            .background(.black.opacity(0.25))
            .cornerRadius(8)
        }
    }
}

struct ControlModePicker: View {
    @Binding var selectedControlModel: Int
    let controlModes = ControlModes.allCases
    
    init(selectedControlModel: Binding<Int>) {
        self._selectedControlModel = selectedControlModel
        UISegmentedControl.appearance().selectedSegmentTintColor = .clear
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.orange], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        UISegmentedControl.appearance().backgroundColor = UIColor(Color.black.opacity(0.25))
    }
    
    var body: some View {
        Picker(selection: $selectedControlModel, label: Text("Select a Control Model")) {
            ForEach(0..<controlModes.count, id: \.self) { index in
                Text(self.controlModes[index].rawValue.uppercased()).tag(index)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .frame(maxWidth: 200)
    }
}

struct ControlButtonBar: View {
    @Binding var showBrowse: Bool
    @Binding var showSettings: Bool
    var selectedControlMode: Int
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 10) {
            if selectedControlMode == 1 {
                SceneButtons()
            } else {
                BrowseButtons(showBrowse: $showBrowse, showSettings: $showSettings)
            }
        }
        .background(.black.opacity(0.25))
        .cornerRadius(8)
    }
}

struct BrowseButtons: View {
    @EnvironmentObject var placementSettings: PlacementSettingsViewModel
    @Binding var showBrowse: Bool
    @Binding var showSettings: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            MostRecentlyPlacedButton().hidden(self.placementSettings.recentlyPlaced.isEmpty)
            
            ControlButton(systemIconName: "square.grid.2x2") {
                self.showBrowse.toggle()
            }.sheet(isPresented: $showBrowse) {
                BrowseView(showBrowse: $showBrowse)
                    .environmentObject(placementSettings)
            }
            
            ControlButton(systemIconName: "slider.horizontal.3") {
                self.showSettings.toggle()
            }.sheet(isPresented: $showSettings) {
                ARSettingsView(showSettings: $showSettings)
            }
        }
    }
}

struct SceneButtons: View {
    @EnvironmentObject var sceneManager: SceneManager
    
    var body: some View {
        HStack(spacing: 10) {
            ControlButton(systemIconName: "icloud.and.arrow.up") {
                self.sceneManager.shouldSaveSceneToFilesystem = true
            }
            .hidden(!self.sceneManager.isPersistanceAvailable)
            
            ControlButton(systemIconName: "icloud.and.arrow.down") {
                self.sceneManager.shouldLoadSceneFromFilesystem = true
            }
            .hidden(self.sceneManager.scenePersistenceData == nil)
            
            ControlButton(systemIconName: "trash") {
                for anchorEntity in sceneManager.anchorEntities {
                    anchorEntity.removeFromParent()
                }
            }
        }
    }
}

struct ControlButton: View {
    let systemIconName: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            self.action()
        }) {
            Image(systemName: systemIconName)
                .font(.system(size: 35))
                .foregroundStyle(.white)
                .buttonStyle(PlainButtonStyle())
        }
        .frame(width: 50, height: 50)
        .background(.black.opacity(0.25))
        .cornerRadius(8)
    }
}

struct MostRecentlyPlacedButton: View {
    @EnvironmentObject var placementSettings: PlacementSettingsViewModel
    
    var body: some View {
        Button(action: {
            self.placementSettings.selectedModel = self.placementSettings.recentlyPlaced.last
        }) {
            if let mostRecentlyPlacedModel = self.placementSettings.recentlyPlaced.last {
                Image(uiImage: mostRecentlyPlacedModel.thumbnail)
                    .resizable()
                    .frame(width: 46)
                    .aspectRatio(1/1, contentMode: .fit)
            } else {
                Image(systemName: "clock.fill")
                    .font(.system(size: 35))
                    .foregroundColor(.white)
                    .buttonStyle(PlainButtonStyle())
            }
        }
        .frame(width: 50, height: 50)
        .background(.white)
        .cornerRadius(8)
    }
}
