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
                                if let url = add.imageURL, let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .frame(width: .none, height: 180)
                                        .scaledToFit()
                                        .cornerRadius(15)
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
