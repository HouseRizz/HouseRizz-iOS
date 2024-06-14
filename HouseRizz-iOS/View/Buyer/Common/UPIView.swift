//
//  UPIView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 14/06/24.
//

import SwiftUI

struct UPIView: View {
    @StateObject private var viewModel = UPIViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(viewModel.installedAppList, id: \.self) { app in
                            UPIListView(model: app, viewModel: viewModel)
                                .padding(.vertical)
                        }
                        
                    }
                    .padding()
                }
                
                Divider()
                
                HRCartButton(buttonText: "Pay Now") {
                    viewModel.launchIntentURLFromStr(intent: viewModel.selectedApp, payeeVPA: "9999670308@pz", payeeName: "Krish Mittal", amount: "2", currencyCode: "INR", transactionNote: "UPI Transaction Test")
                }
                .padding()
            }
            .padding(.vertical)
            .navigationTitle("Select the Installed UPI Apps to Continue")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct UPIListView: View {
    var model: UPIAppListViewDataModel
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

#Preview {
    UPIView()
}
