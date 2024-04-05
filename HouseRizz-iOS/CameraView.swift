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
    @State private var selectedModel: String?
    @State private var isPlacementEnabled = false
    @State private var modelConfirmedForPlacement: String?

    var body: some View {
        ZStack(alignment: .bottom) {
            CustomARViewContainer(
                selectedModel: $selectedModel,
                isPlacementEnabled: $isPlacementEnabled
            )
            
            if !isPlacementEnabled {
                ModelPickerView(
                    isPlacementEnabled: $isPlacementEnabled,
                    selectedModel: $selectedModel,
                    models: modelNames
                )
            }

            if isPlacementEnabled {
                PlacementButtonView(
                    isPlacementEnabled: $isPlacementEnabled,
                    selectedModel: $selectedModel,
                    modelConfirmedForPlacement: $modelConfirmedForPlacement
                )
            }
        }
    }
}

struct CustomARViewContainer: UIViewRepresentable {
    @Binding var selectedModel: String?
    @Binding var isPlacementEnabled: Bool

    func makeUIView(context: Context) -> CustomARView {
        return CustomARView(
            selectedModel: $selectedModel,
            isPlacementEnabled: $isPlacementEnabled
        )
    }

    func updateUIView(_ uiView: CustomARView, context: Context) {}
}

class CustomARView: ARView {
    @Binding var selectedModel: String?
    @Binding var isPlacementEnabled: Bool

    var focusEntity: FocusEntity?
    var cancellables: Set<AnyCancellable> = []

    init(selectedModel: Binding<String?>, isPlacementEnabled: Binding<Bool>) {
        self._selectedModel = selectedModel
        self._isPlacementEnabled = isPlacementEnabled
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
                    print("Removing 3D model: has not been implemented")
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
    private init() {}
    var actionStream = PassthroughSubject<Actions, Never>()
}

struct ModelPickerView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: String?
    var models: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 30) {
                ForEach(0 ..< self.models.count) { index in
                    Button {
                        selectedModel = models[index]
                        isPlacementEnabled = true
                    } label: {
                        Image(uiImage: UIImage(named: self.models[index])!)
                            .resizable()
                            .frame(height: 80)
                            .aspectRatio(1/1, contentMode: .fit)
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(20)
        .background(Color.black.opacity(0.5))
    }
}

struct PlacementButtonView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: String?
    @Binding var modelConfirmedForPlacement: String?

    var body: some View {
        HStack {
            Button {
                resetPlacementParameters()
            } label: {
                Image(systemName: "xmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(30)
                    .padding(20)
            }
            Button {
                if let selectedModel = selectedModel {
                    ActionManager.shared.actionStream.send(.place3DModel(modelName: selectedModel))
                }
                modelConfirmedForPlacement = selectedModel
                resetPlacementParameters()
            } label: {
                Image(systemName: "checkmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(30)
                    .padding(20)
            }
        }
    }

    func resetPlacementParameters() {
        isPlacementEnabled = false
        selectedModel = nil
    }
}
