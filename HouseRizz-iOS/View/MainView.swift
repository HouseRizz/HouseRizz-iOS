//
//  ContentView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 04/04/24.
//

import SwiftUI

struct MainView: View {
    @StateObject var viewModel = Authentication()
    
    var body: some View {
        if viewModel.isSignedIn, !viewModel.currentUserId.isEmpty {
            SideMenuView()
        } else {
            LoginView()
        }
    }
}

#Preview {
    MainView()
}
