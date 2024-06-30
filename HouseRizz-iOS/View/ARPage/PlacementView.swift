//
//  PlacementView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 28/06/24.
//

import SwiftUI

struct PlacementView: View {
    @EnvironmentObject var placementSettigns: PlacementSettingsViewModel
    var body: some View {
        HStack {
            Spacer()
            PlacementButton(sysytemIconName: "xmark.circle.fill") {
                self.placementSettigns.selectedModel = nil
            }
            
            PlacementButton(sysytemIconName: "checkmark.circle.fill") {
                let modelAnchor = ModelAnchor(model: self.placementSettigns.selectedModel!, anchor: nil)
                self.placementSettigns.modelsConfirmedForPlacement.append(modelAnchor)
                self.placementSettigns.selectedModel = nil
            }
            Spacer()
        }
        .padding(.bottom, 30)
    }
}

struct PlacementButton: View {
    let sysytemIconName: String
    let action: () -> Void
    var body: some View {
        Button(action: {
            self.action()
        }) {
            Image(systemName: sysytemIconName)
                .font(.system(size: 50, weight: .light, design: .default))
                .foregroundColor(.white)
                .buttonStyle(PlainButtonStyle())
        }
        .frame(width: 75, height: 75)
    }
}

#Preview {
    PlacementView()
}
