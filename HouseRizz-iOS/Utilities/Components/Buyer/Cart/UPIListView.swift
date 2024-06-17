//
//  UPIListView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 14/06/24.
//

import SwiftUI

struct UPIListView: View {
    var model: UPIListItemModel
    @ObservedObject var viewModel: UPIViewModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack {
            Image(systemName: viewModel.selectedApp == model.appScheme ? "circle.fill" : "circle")
                .padding(.leading)
                .foregroundStyle(Color.primaryColor)
            
            Text(model.appname)
                .font(.title3)
                .textCase(.uppercase)
    
            Spacer()
            
            Image(uiImage: model.imageURL ?? UIImage(named: "defaultUPI")!)
                .resizable()
                .frame(width: 40, height: 40)
                .cornerRadius(10)
                .padding(.trailing)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(colorScheme == .dark ? Color.black : Color.white)
        .cornerRadius(8)
        .shadow(color: colorScheme == .dark ? Color.white.opacity(0.2) : Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
        .onTapGesture {
            viewModel.selectedApp = model.appScheme
        }
    }
}
