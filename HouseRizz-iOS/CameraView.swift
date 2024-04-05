//
//  CameraView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 04/04/24.
//

import SwiftUI
import RealityKit
import ARKit
import FocusEntity
import Combine

struct CameraView: View {
    
    let modelNames = ["retrotv", "redchair"]
    @State private var selectedModelIndex = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            CustomARViewContainer(selectedModel: modelNames[selectedModelIndex])
            
            Picker(selection: $selectedModelIndex, label: Text("Select Model")) {
                ForEach(0..<modelNames.count, id: \.self) { index in
                    VStack {
                        Image(modelNames[index])
                            .resizable()
                            .frame(width: 50, height: 50)
                            .tag(index)
                        Text(modelNames[index]).tag(index)
                    }
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            Button(action: {
                ActionManager.shared.actionStream.send(.place3DModel(modelName: modelNames[selectedModelIndex]))
            }, label: {
                Text("Place 3D Model")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            })
            .padding(.bottom, 50)
        }
    }
}

struct CustomARViewContainer: UIViewRepresentable {
    
    let selectedModel: String
    
    func makeUIView(context: Context) -> CustomARView {
        return CustomARView(selectedModel: selectedModel)
    }
    
    func updateUIView(_ uiView: CustomARView, context: Context) {}
}

class CustomARView: ARView {
    
    var focusEntity: FocusEntity?
    var cancellables: Set<AnyCancellable> = []
    let selectedModel: String
    
    init(selectedModel: String) {
        self.selectedModel = selectedModel
        super.init(frame: .zero)
        
        subscribeToActionStream()
        
        self.focusEntity = FocusEntity(on: self, style: .classic(color: .yellow))
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.meshWithClassification) {
            config.sceneReconstruction = .meshWithClassification
        }
        
        self.environment.sceneUnderstanding.options.insert(.occlusion)
        
        self.session.run(config)
    }
    
    
    func place3DModel(modelName: String) {
        guard let focusEntity = self.focusEntity else { return }
        
        let modelEntity = try! ModelEntity.load(named: "\(modelName).usdz")
        let anchorEntity = AnchorEntity(world: focusEntity.position)
        anchorEntity.addChild(modelEntity)
        self.scene.addAnchor(anchorEntity)
    }
    
    
    func subscribeToActionStream() {
        ActionManager.shared
            .actionStream
            .sink { [weak self] action in
                
                switch action {
                    
                case .place3DModel(let modelName):
                    self?.place3DModel(modelName: modelName)
                    
                case .remove3DModel:
                    print("Removeing 3D model: has not been implemented")
                }
            }
            .store(in: &cancellables)
    }
    
    @MainActor required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @MainActor required dynamic init(frame frameRect: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
}

enum Actions {
    case place3DModel(modelName: String)
    case remove3DModel
}

class ActionManager {
    static let shared = ActionManager()
    
    private init() { }
    
    var actionStream = PassthroughSubject<Actions, Never>()
}
