//
//  AddAIVibeView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 21/06/24.
//

import SwiftUI
import PhotosUI

struct AddAIVibeView: View {
    @State private var viewModel = AddAIVibeViewModel()
    @State private var photoPickerItems = [PhotosPickerItem]()
    @State private var showFilePicker = false
    @State private var tempFileURL: URL?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            VStack {
                vibePhotoPicker
                
                TextField("Vibe Name", text: $viewModel.name)
                    .customTextFieldStyle()
                
                Divider()
                
                HRAddProductButton(buttonText: "Save", background: Color.primaryColor, textColor: .white) {
                    viewModel.addButtonPressed()
                }
            }
            .padding()
        }
        .navigationTitle("Add Vibe")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Photo Picker UI + Logic
extension AddAIVibeView {
    @ViewBuilder
    var vibePhotoPicker: some View {
        HStack {
            Text("Upload photos(max. 1)")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.gray)
            
            Spacer()
            
            PhotosPicker(selection: $photoPickerItems, maxSelectionCount: 3, matching: .images) {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .frame(width: 60,height: 40)
                        .foregroundStyle(Color.secondaryColor)
                    Text("Add")
                        .font(.system(.title3, design: .rounded))
                        .bold()
                        .foregroundStyle(Color.primaryColor)
                }
            }
            .onChange(of: photoPickerItems) {
                Task {
                    viewModel.selectedPhotoData.removeAll()
                    for item in photoPickerItems {
                        if let imageData = try await item.loadTransferable(type: Data.self) {
                            viewModel.selectedPhotoData.append(imageData)
                        }
                    }
                }
            }
        }
        
        if viewModel.selectedPhotoData.count > 0 {
            ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(0..<viewModel.selectedPhotoData.count, id: \.self) { index in
                        ZStack {
                            Rectangle()
                                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [3]))
                            
                            Image(uiImage: UIImage(data: viewModel.selectedPhotoData[index])!)
                                .cornerRadius(5)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                        }
                    }
                }
            }
            .cornerRadius(5)
            .frame(maxWidth: .infinity)
        } else {
            ZStack {
                Color.gray.opacity(0.2)
                
                Rectangle()
                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [3]))
                
                Text("Add Photos")
                    .font(.system(.subheadline, design: .rounded))
            }
            .foregroundStyle(.gray)
            .cornerRadius(5)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
        }
    }
    
}

#Preview {
    AddAIVibeView()
}
