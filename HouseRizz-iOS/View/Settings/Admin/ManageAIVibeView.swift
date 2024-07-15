//
//  ManageAIVibeView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 21/06/24.
//

import SwiftUI

struct ManageAIVibeView: View {
    @State private var viewModel = ManageAIVibeViewModel()
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(viewModel.vibes.indices, id: \.self) { index in
                            let vibe = viewModel.vibes[index]
                            VStack {
                                if let url = vibe.imageURL, let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(.gray, lineWidth: 0.5)
                                        )
                                }
                                
                                VStack {
                                    Text(vibe.name)
                                        .bold()
                                        .font(.subheadline)
                                        .padding(.vertical, 1)
                                        .lineLimit(2)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Spacer()
                                }
                            }
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
            .navigationTitle("AI Vibes")
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
