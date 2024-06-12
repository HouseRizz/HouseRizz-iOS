//
//  SearchView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 11/04/24.
//

import SwiftUI

struct SearchView: View {
    @State private var search: String = ""
    @EnvironmentObject var cartViewModel: CartViewModel
    
    var body: some View {
        HStack {
            HStack {
                HStack {
                    Image(systemName: "mappin")
                    
                    VStack(alignment: .leading) {
                        Text("Delivery to")
                        Text("Delhi")
                    }
                    .font(.caption)
                }
                .padding(.leading, 15)
                
                Spacer()
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .padding(5)
                    
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName:  "person")
                            .padding(5)
                    }
                    
                    NavigationLink(destination: CartView().environmentObject(cartViewModel)) {
                        CartButton(numberOfProducts: cartViewModel.products.count)
                    }
                }
                .padding(.trailing, 15)
            }
            .padding()
            .background(Color.orange.opacity(0.2))
            .cornerRadius(25)
        }
        .padding(.horizontal)
    }
}
