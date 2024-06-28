//
//  ARSettingsView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 28/06/24.
//

import SwiftUI

enum ARSettings {
    case peopleOcclusion
    case objectOcclusion
    case lidarDebug
//    case multiUser
    
    var label: String {
        get {
            switch self {
            case .peopleOcclusion, .objectOcclusion:
                return "Occlusion"
            case .lidarDebug:
                return "LiDAR"
//            case .multiUser:
//                return "Multiuser"
            }
        }
    }
    
    var systemIconName: String {
        get {
            switch self {
            case .peopleOcclusion:
                return "person"
            case .objectOcclusion:
                return "cube.box.fill"
            case .lidarDebug:
                return "light.min"
//            case .multiUser:
//                return "person.2"
            }
        }
    }
}

struct ARSettingsView: View {
    @Binding var showSettings: Bool
    var body: some View {
        NavigationStack {
            ARSettingsGrid()
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {self.showSettings.toggle()}) {
                            Text("Done").bold()
                        }
                    }
                }
        }
    }
}

struct ARSettingsGrid: View {
    @EnvironmentObject var sessionSettings: ARSessionSettingsViewModel
    private var gridItemLayout = [GridItem(.adaptive(minimum: 100, maximum: 100), spacing: 25)]
    var body: some View {
        ScrollView {
            LazyVGrid(columns: gridItemLayout, spacing: 25) {
                ARSettingsToggleButton(setting: .peopleOcclusion, isOn: $sessionSettings.isPeopleOcclusionEnabled)
                ARSettingsToggleButton(setting: .objectOcclusion, isOn: $sessionSettings.isObjectOcclusionEnabled)
                ARSettingsToggleButton(setting: .lidarDebug, isOn: $sessionSettings.isLidarDebugEnabled)
//                ARSettingsToggleButton(setting: .multiUser, isOn: $sessionSettings.isMultiuserEnabled)
            }
        }
    }
}


struct ARSettingsToggleButton: View {
    let setting: ARSettings
    @Binding var isOn: Bool
    
    var body: some View {
        Button(action: {
            self.isOn.toggle()
        }) {
            VStack {
                Image(systemName: setting.systemIconName)
                    .font(.system(size: 35))
                    .foregroundStyle(self.isOn ? .green : Color(UIColor.secondaryLabel))
                    .padding(.top, 5)
            }
        }
        .frame(width: 100, height: 100)
        .background(Color(UIColor.secondarySystemFill))
        .cornerRadius(20.0)
    }
}

