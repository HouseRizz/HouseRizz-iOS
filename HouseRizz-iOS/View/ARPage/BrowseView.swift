//
//  BrowseView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 28/06/24.
//

import SwiftUI

struct BrowseView: View {
    @Binding var showBrowse: Bool
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                RecentsGrid(showBrowse: $showBrowse)
                ModelsByCategoryGrid(showBrowse: $showBrowse)
            }
            .navigationTitle("Browse")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        self.showBrowse.toggle()
                    } label: {
                        Text("Done")
                            .bold()
                    }
                }
            }
        }
    }
}

struct ModelsByCategoryGrid: View {
    @Binding var showBrowse: Bool

    @ObservedObject private var viewModel = HR3DModelViewModel()
    
    var body: some View {
        VStack {
            ForEach(ModelCategory.allCases, id: \.self) { category in
                let modelsByCategory = viewModel.models.filter( {$0.category == category})
                if !(modelsByCategory.isEmpty) {
                    HorizontalGrid(showBrowse: $showBrowse, title: category.label, items: modelsByCategory)
                }
            }
        }
        .onAppear() {
            self.viewModel.fetchData()
        }
    }
}

struct HorizontalGrid: View {
    @EnvironmentObject var placementSettings: PlacementSettingsViewModel
    @Binding var showBrowse: Bool

    var title: String
    var items: [HR3DModel]
    private let gridItemLayout = [GridItem(.fixed(150))]
    var body: some View {
        VStack (alignment: .leading) {
            Sepator()
            
            Text(title)
                .font(.title2).bold()
                .padding(.leading, 22)
                .padding(.top, 10)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: gridItemLayout, spacing: 30) {
                    ForEach( 0..<items.count, id: \.self ) { index in
                        let model = items[index]
                        ItemButton(model: model) {
                            model.asyncLoadModelEntity()
                            self.placementSettings.selectedModel = model
                            self.showBrowse = false
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.vertical, 10)
                }
            }
        }
    }
}

struct ItemButton: View {
    @ObservedObject var model: HR3DModel
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            self.action()
        }) {
            Image(uiImage: self.model.thumbnail)
                .resizable()
                .frame(height: 150)
                .aspectRatio(1/1, contentMode: .fit)
                .background(Color(UIColor.secondarySystemFill))
                .cornerRadius(8.0)
        }
    }
}

struct Sepator: View {
    var body: some View {
        Divider()
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
    }
}

struct RecentsGrid: View {
    @EnvironmentObject var placementSettings: PlacementSettingsViewModel
    @Binding var showBrowse: Bool

    var body: some View {
        if !self.placementSettings.recentlyPlaced.isEmpty {
            HorizontalGrid(showBrowse: $showBrowse, title: "Recents", items: getRecentsUniqueOrdered())
        }
    }
    
    func getRecentsUniqueOrdered() -> [HR3DModel] {
        var recentsUniqueOrderedArray: [HR3DModel] = []
        var modelNameSet: Set<String> = []
        
        for model in self.placementSettings.recentlyPlaced.reversed() {
            if !modelNameSet.contains(model.name) {
                recentsUniqueOrderedArray.append(model)
                modelNameSet.insert(model.name)
            }
        }
        
        return recentsUniqueOrderedArray
    }
}
