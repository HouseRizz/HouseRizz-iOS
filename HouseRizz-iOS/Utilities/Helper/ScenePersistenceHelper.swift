//
//  ScenePersistenceHelper.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 30/06/24.
//

import Foundation
import RealityKit
import ARKit

class ScenePersistenceHelper {
    class func saveScene(for arView: CustomARView, at persistenceUrl: URL) {
        arView.session.getCurrentWorldMap { worldMap, error in
            guard let map = worldMap else {
                return
            }
            
            do {
                let sceneData = try NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
                try sceneData.write(to: persistenceUrl, options: [.atomic])
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    class func loadScene(for arView: CustomARView, with scenePersistenceData: Data) {
        let worldMap: ARWorldMap = {
            do {
                guard let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: scenePersistenceData) else {
                    fatalError("No ARWorldMap")
                }
                
                return worldMap
            } catch {
                fatalError("No ARWorldMap")
            }
        }()
        
        let newConfig = arView.defaultConfigutaion
        newConfig.initialWorldMap = worldMap
        arView.session.run(newConfig, options: [.resetTracking, .removeExistingAnchors])
    }
}
