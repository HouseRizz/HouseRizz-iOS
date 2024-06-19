//
//  AdminInventoryView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 19/06/24.
//

import SwiftUI

struct AdminInventoryView: View {
    @StateObject private var viewModel = AdminInventoryViewModel()
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    @State private var showDeleteOption: Bool = false
    @StateObject private var authentication = Authentication()
    
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
                                    InventoryProductCardView(product: viewModel.products[index])
                                    
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
                .onAppear {
                    viewModel.fetchItems()
                }
                .refreshable {
                    viewModel.fetchItems()
                }
            }
            .navigationTitle("All Products")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
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


#Preview {
    AdminInventoryView()
}
