//
//  ContentView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 04/04/24.
//

import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = Authentication()
    @StateObject private var networkManager = NetworkManager()
    
    var body: some View {
        Group {
            if networkManager.isConnected {
                displayContentView()
            } else {
                NoNetworkView()
            }
        }
    }
    
    @ViewBuilder
    private func displayContentView() -> some View {
        if viewModel.isLoading {
            LaunchScreenView()
        } else if viewModel.isSignedIn, !viewModel.currentUserId.isEmpty {
            TabbedView()
        } else {
            AuthenticationView()
        }
    }
}

#Preview {
    MainView()
}
