//
//  ManageAIVibeView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 21/06/24.
//

import SwiftUI

struct ManageAIVibeView: View {
    @State private var viewModel = ManageAIVibeViewModel()
    let columns = [GridItem(.flexible()), GridItem(.flexible()),GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(viewModel.vibes.indices, id: \.self) { category in
//                            NavigationLink(destination: ProductCategoryView(productCategory: viewModel.categories[category])) {
//                                CategoryCard(category: viewModel.categories[category])
//                            }
                        }
                    }
                    .padding()
                }
            }
            .onAppear {
                viewModel.fetchVibes()
            }
            .refreshable {
                viewModel.fetchVibes()
            }
            .navigationTitle("Product Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        AddAIVibeView()
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
    ManageAIVibeView()
}
