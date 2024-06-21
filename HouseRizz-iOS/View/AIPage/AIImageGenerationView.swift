//  AIImageGenerationView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 20/06/24.
//

import SwiftUI
import PhotosUI

struct AIImageGenerationView: View {
    @State private var viewModel = AIImageGenerationViewModel()
    @State private var isLoading = false
    @State private var navigateToGeneratedPhotoView = false
    @State private var hasReturnedFromGeneratedPhotoView = false
    @State var uniqueID: UUID = UUID()
    @State private var showAllResults: Bool = false
    @StateObject private var authentication = Authentication()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Design Your Home")
                        .font(.title)
                        .bold()
                    
                    Text("Choose a Room")
                        .font(.title3)
                        .bold()
                    
                    GeometryReader { reader in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(viewModel.categories.indices, id: \.self) { category in
                                    Button {
                                        viewModel.type = viewModel.categories[category].name
                                    } label: {
                                        VStack {
                                            if let url = viewModel.categories[category].imageURL, let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                                                Image(uiImage: image)
                                                    .resizable()
                                                    .background(Color.primaryColor)
                                                    .scaledToFill()
                                                    .frame(width: reader.size.width * 0.4, height: reader.size.width * 0.4 * 1.4)
                                                    .overlay {
                                                        RoundedRectangle(cornerRadius: 20).stroke(Color.primaryColor, lineWidth: viewModel.categories[category].name == viewModel.type ? 3 : 0)
                                                    }
                                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                            }
                                            
                                            Text(viewModel.categories[category].name)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .frame(height: 250)
                    
                    Text("Choose a Style")
                        .font(.title3)
                        .bold()
                    
                    GeometryReader { reader in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(ImageStyle.allCases, id: \.self) { imageStyle in
                                    Button {
                                        viewModel.vibe = imageStyle.title
                                    } label: {
                                        VStack {
                                            Image(imageStyle.rawValue)
                                                .resizable()
                                                .background(Color.primaryColor)
                                                .scaledToFill()
                                                .frame(width: reader.size.width * 0.4, height: reader.size.width * 0.4 * 1.4)
                                                .overlay {
                                                    RoundedRectangle(cornerRadius: 20).stroke(Color.primaryColor, lineWidth: imageStyle.title == viewModel.vibe ? 3 : 0)
                                                }
                                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                            
                                            Text(imageStyle.title)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .frame(height: 250)
                    
                    Text("Add Photo")
                        .font(.title3)
                        .bold()
                    
                    VStack(alignment: .center) {
                        PhotosPicker(
                            selection: $viewModel.selectedPhotos,
                            maxSelectionCount: 1,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            if let data = viewModel.selectedPhotoData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                            } else {
                                ZStack {
                                    Color.gray.opacity(0.2)
                                    
                                    Rectangle()
                                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [3]))
                                    
                                    Text("Add Photo")
                                        .font(.system(.subheadline, design: .rounded))
                                }
                                .foregroundStyle(.gray)
                                .cornerRadius(5)
                                .frame(maxWidth: .infinity)
                                .frame(height: 200)
                            }
                        }
                        .onChange(of: viewModel.selectedPhotos, { _, _ in
                            viewModel.loadSelectedPhoto()
                        })
                    }
                    
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .padding()
                    } else {
                        Button {
                            isLoading = true
                            Task {
                                try? await viewModel.generate()
                                isLoading = false
                            }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .foregroundStyle(Color.primaryColor)
                                
                                Text("Design")
                                    .bold()
                            }
                        }
                        .padding()
                    }
                    
                    if let prediction = viewModel.prediction, let url = prediction.output, !hasReturnedFromGeneratedPhotoView {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .foregroundStyle(Color.primaryColor)
                            
                            Text("See Results")
                                .bold()
                        }
                        .padding()
                        .onAppear {
                            viewModel.user = authentication.user?.email ?? "Not Provided"
                            viewModel.imageURL = url.absoluteString
                            viewModel.uniqueID = uniqueID
                            viewModel.addButtonPressed()
                            navigateToGeneratedPhotoView.toggle()
                        }
                    } else {
                        Text("")
                    }
                    
                }
                .navigationDestination(isPresented: $navigateToGeneratedPhotoView) {
                    GeneratedPhotoView(uniqueID: uniqueID)
                }
                .navigationDestination(isPresented: $showAllResults) {
                    AllUserAIImageGenerationView(authentication: authentication)
                }
//                .toolbar {
//                    ToolbarItem(placement: .topBarTrailing) {
//                        Image(systemName: "plus")
//                            .onTapGesture {
//                                showAllResults.toggle()
//                            }
//                    }
//                }
                .padding()
            }
        }
        .onChange(of: navigateToGeneratedPhotoView) { _, newValue in
            if !newValue {
                hasReturnedFromGeneratedPhotoView = true
                viewModel.prediction = nil
                viewModel.selectedPhotoData = nil
                viewModel.selectedPhotos = []
            }
        }
    }
}

#Preview {
    AIImageGenerationView()
}
