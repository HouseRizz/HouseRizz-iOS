//
//  APIView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 20/06/24.
//

import SwiftUI

struct APIView: View {
    @StateObject private var viewModel = APIViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    TextField("API Name", text: $viewModel.name)
                        .customTextFieldStyle()
                    TextField("API", text: $viewModel.api)
                        .customTextFieldStyle()
                }
                
                HRAddProductButton(buttonText: "Save", background: Color.primaryColor, textColor: .white) {
                    viewModel.addButtonPressed()
                }
                
                List(viewModel.apis, id: \.self) { api in
                    HStack {
                        Text(api.name)
                        Text(api.api)
                    }
                }
            }
            .navigationTitle("Manage All API")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.fetchAPI()
            }
            .refreshable {
                viewModel.fetchAPI()
            }
            .padding()
        }
    }
}

#Preview {
    APIView()
}
