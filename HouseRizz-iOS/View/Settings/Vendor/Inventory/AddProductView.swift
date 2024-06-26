//
//  AddProductView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 20/05/24.
//

import SwiftUI
import PhotosUI

struct AddProductView: View {
    @StateObject private var viewModel = AddProductViewModel()
    @State private var photoPickerItems = [PhotosPickerItem]()
    @State private var showFilePicker = false
    @State private var tempFileURL: URL?
    @State var isSaveButton: Bool = false
    @State var isAddButton: Bool = false
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var authentication = Authentication()
    
    var body: some View {
        NavigationStack {
            VStack {
                Divider()
                
                ScrollView {
                    VStack {
                        photoPicker
                        
                        categoryPicker
                        
                        textFields
                        
                        threedmodel
                    }
                }
                
                Divider()
                
                if viewModel.isLoaded {
                    ProgressView().tint(Color.primaryColor)
                } else {
                    saveButtons
                }
            }
            .padding()
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .alert(viewModel.isSuccess ? "Success" : "Failure", isPresented: $viewModel.isLoaded) {
                Button("Ok", role: .cancel ) {
                    if isSaveButton {
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        viewModel.clearItem()
                    }
                }
            } message: {
                Text(viewModel.isSuccess ? "Uploaded Successfully" : viewModel.error)
            }
        }
    }
}

extension AddProductView {
    
    var saveButtons: some View {
        HStack {
            HRAddProductButton(buttonText: "Save", background: Color.primaryColor, textColor: .white) {
                viewModel.address = authentication.user?.address ?? "Not Provided"
                viewModel.addButtonPressed(vendorName: authentication.user?.name ?? "none")
                isSaveButton = true
            }
            
            HRAddProductButton(buttonText: "Add Another", background: Color.primaryColor.opacity(0.2), textColor: Color.primaryColor) {
                viewModel.address = authentication.user?.address ?? "Not Provided"
                viewModel.addButtonPressed(vendorName: authentication.user?.name ?? "none")
                isAddButton = true
            }
        }
    }
    
    var threedmodel: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Add 3D Model") + Text(" (Optional)")
                    .foregroundStyle(.gray)
                
                Spacer()
                
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .frame(width: 140,height: 40)
                        .foregroundStyle(Color.secondaryColor)
                    Button {
                        showFilePicker.toggle()
                    } label: {
                        Text("Upload Model")
                            .font(.system(.title3, design: .rounded))
                            .bold()
                            .foregroundStyle(Color.primaryColor)
                    }
                    .fileImporter(isPresented: $showFilePicker, allowedContentTypes: [.usdz]) { result in
                        viewModel.loadUSDZFile(from: result)
                    }
                    
                }
            }
        }
    }
    
    var textFields: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            TextField("Item Name", text: $viewModel.name)
                .customTextFieldStyle()
            
            TextField("Description", text: $viewModel.description, axis: .vertical)
                .customTextFieldStyle()
            
            VStack(alignment: .leading) {
                Text("Price")
                    .foregroundStyle(.gray)
                
                TextField("Price", value: $viewModel.sellingPrice, formatter: NumberFormatter.currencyFormatter)
                    .customTextFieldStyle()
            }
            
            VStack(alignment: .leading)  {
                Text("Tax Rate")
                    .foregroundStyle(.gray)
                
                TextField("Tax", value: $viewModel.taxRate, formatter: NumberFormatter.currencyFormatter)
                    .customTextFieldStyle()
            }
            
            Text("Final Price: \(viewModel.finalPrice.formattedCurrency())")
        }
    }
    
    var categoryPicker: some View {
        HStack {
            Text("Set Category")
            
            Spacer()
            
            Picker("Category", selection: $viewModel.selectedCategoryIndex) {
                ForEach(viewModel.categories.indices, id: \.self) { index in
                    Text(viewModel.categories[index].name).tag(index)
                }
            }
        }
    }
}

// Photo Picker UI + Logic
extension AddProductView {
    @ViewBuilder
    var photoPicker: some View {
        HStack {
            Text("Upload photos(max. 3)")
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
                        Image(uiImage: UIImage(data: viewModel.selectedPhotoData[index])!)
                            .resizable()
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
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
    AddProductView()
}
