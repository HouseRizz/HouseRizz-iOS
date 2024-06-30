//
//  DeletionView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 30/06/24.
//

import SwiftUI

struct DeletionView: View {
    @EnvironmentObject var sceneManger: SceneManager
    @EnvironmentObject var modelDeletionManger: ModelDeletionManager
    
    var body: some View {
        HStack {
            Spacer()
            
            DeletionButton(sysytemIconName: "xmark.circle.fill") {
                self.modelDeletionManger.entitySelectedForDeletion = nil
            }
            
            Spacer()
            
            DeletionButton(sysytemIconName: "trash.circle.fill") {
                guard let anchor = self.modelDeletionManger.entitySelectedForDeletion?.anchor else { return }
                
                let anchoringIdentifier = anchor.anchorIdentifier
                if let index = self.sceneManger.anchorEntities.firstIndex(where: { $0.anchorIdentifier == anchoringIdentifier}) {
                    self.sceneManger.anchorEntities.remove(at: index) // Optimize this as all the elemets to the right will also have to shift
                }
                anchor.removeFromParent()
                self.modelDeletionManger.entitySelectedForDeletion = nil
            }
            
            Spacer()
        }
        .padding(.bottom, 30)
    }
}

struct DeletionButton: View {
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
    DeletionView()
}
