//
//  ManageAddBannerView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 19/06/24.
//

import SwiftUI

struct ManageAddBannerView: View {
    @StateObject private var viewModel = ManageAddBannerViewModel()
    @State private var showDeleteOption: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    ForEach(viewModel.adds.indices, id: \.self) { index in
                        let add = viewModel.adds[index]
                        ZStack(alignment: .topTrailing) {
                            VStack {
                                if let url = add.imageURLValue {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .frame(width: .none, height: 180)
                                                .scaledToFit()
                                                .cornerRadius(15)
                                        case .failure(_):
                                            Image(systemName: "photo")
                                                .resizable()
                                                .frame(width: .none, height: 180)
                                                .foregroundColor(.gray)
                                        case .empty:
                                            ProgressView()
                                                .frame(width: .none, height: 180)
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                }
                                
                                HStack {
                                    Text("\(add.name)")
                                    Text("\(add.sliderNumber)")
                                }
                            }
                            
                            Image(systemName: "minus.circle.fill")
                                .imageScale(.large)
                                .bold()
                                .foregroundStyle(.red)
                                .opacity(showDeleteOption ? 1.0 : 0.0)
                                .onTapGesture {
                                    viewModel.deleteItem(indexSet: IndexSet(integer: index))
                                }
                        }
                    }
                    .padding()
                }
            }
            .onAppear {
                viewModel.fetchAddBanners()
            }
            .refreshable {
                viewModel.fetchAddBanners()
            }
            .navigationTitle("Manage Add Banners")
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
                
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        AddAddBannerView()
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
    ManageAddBannerView()
}
