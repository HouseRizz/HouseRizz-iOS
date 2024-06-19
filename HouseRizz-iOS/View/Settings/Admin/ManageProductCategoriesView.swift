//
//  ManageProductCategoriesView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 19/06/24.
//

import SwiftUI

struct ManageProductCategoriesView: View {
    @StateObject private var viewModel = ManageProductCategoriesViewModel()
    let columns = [GridItem(.flexible()), GridItem(.flexible()),GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(viewModel.categories.indices, id: \.self) { category in
                            NavigationLink(destination: ProductCategoryView(productCategory: viewModel.categories[category])) {
                                CategoryCard(category: viewModel.categories[category])
                            }
                        }
                    }
                    .padding()
                }
            }
            .onAppear {
                viewModel.fetchCategories()
            }
            .refreshable {
                viewModel.fetchCategories()
            }
            .navigationTitle("Product Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        AddProductCategoriesView()
                            .toolbarRole(.editor)
                    } label: {
                        Image(systemName: "plus.circle")
                            .imageScale(.large)
                            .bold()
                    }
                }
            }
        }
    }
}

#Preview {
    ManageProductCategoriesView()
}
