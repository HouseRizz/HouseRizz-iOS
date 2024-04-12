//
//  SearchView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 11/04/24.
//

import SwiftUI

struct SearchView: View {
    @State private var search: String = ""
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .padding(.leading)
                
                TextField("Search For Furniture", text: $search)
                    .padding()
                
            }
            .background(Color.purple.opacity(0.2))
            .cornerRadius(12)
        }
        .padding()
    }
}

#Preview {
    SearchView()
}
