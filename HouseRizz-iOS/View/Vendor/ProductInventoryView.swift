//
//  VendorProductView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 20/05/24.
//

import SwiftUI

struct ProductInventoryView: View {
    @StateObject private var viewModel = ProductInventoryViewModel()
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    @State private var showDeleteOption: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(viewModel.products.indices, id: \.self) { index in
                            NavigationLink(destination: InventoryProductDetailView(product:viewModel.products[index])
                                .toolbarRole(.editor))
                            {
                                ZStack(alignment: .topLeading) {
                                    VendorProductCardView(product: viewModel.products[index])
                                    
                                    Image(systemName: "minus.circle.fill")
                                        .imageScale(.large)
                                        .bold()
                                        .foregroundStyle(.red)
                                        .opacity(showDeleteOption ? 1.0 : 0.0)
                                        .padding(.top,20)
                                        .onTapGesture {
                                            viewModel.deleteItem(indexSet: IndexSet(integer: index))
                                        }
                                }
                            }
                        }
                    }
                    .padding()
                }
                .refreshable {
                    viewModel.fetchItems()
                }
            }
            .navigationTitle("\(viewModel.userName)'s Products")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        AddProductView()
                            .toolbarRole(.editor)
                    } label: {
                        Image(systemName: "plus.circle")
                            .imageScale(.large)
                            .bold()
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showDeleteOption.toggle()
                    } label: {
                        Image(systemName: showDeleteOption ? "minus.circle.fill": "minus.circle" )
                            .imageScale(.large)
                            .bold()
                            .foregroundStyle(.red)
                    }
                }
            }
        }
    }
    
}
