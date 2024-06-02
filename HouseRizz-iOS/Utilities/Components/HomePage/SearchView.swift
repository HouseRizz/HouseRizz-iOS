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
                TextField("Search For Furniture", text: $search)
                    .padding()
                
                Image(systemName: "magnifyingglass")
                    .padding(.trailing)
                
            }
            .background(Color.orange.opacity(0.2))
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}

#Preview {
    SearchView()
}
