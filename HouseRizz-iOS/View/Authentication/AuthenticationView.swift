//
//  LoginView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 04/04/24.
//

import SwiftUI
import AuthenticationServices

struct AuthenticationView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel = Authentication()
    @State var showLogin = false
    
    private func signInWithGoogle() {
        Task {
            await viewModel.signInWithGoogle()
        }
    }
    
    private func signInAnonymously() {
        Task {
            await viewModel.signInAnonymously()
        }
    }
    
    var body: some View {
        VStack {
            VStack{
                Image("cats")
                    .resizable()
                    .frame(maxWidth: .infinity)
                    .frame(height: 400)
                
                VStack(spacing: 10){
                    HRAuthenticationButton(label: "Continue Without Sign in", iconName: "person") {
                        signInAnonymously()
                    }
                    
                    HStack {
                        VStack { Divider() }
                        Text("or")
                        VStack { Divider() }
                    }
                    
                    HRAuthenticationButton(label: "Sign in with Email", iconName: "envelope.fill") {
                        showLogin.toggle()
                    }
                    
                    HRAuthenticationButton(label: "Sign in with Google", iconImage: Image("google")) {
                        signInWithGoogle()
                    }
                    
                    SignInWithAppleButton(.signIn) { request in
                        viewModel.handleSignInWithAppleRequest(request)
                    } onCompletion: { result in
                        viewModel.handleSignInWithAppleCompletion(result)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .padding(.vertical, 15)
                    .cornerRadius(8)
                    .signInWithAppleButtonStyle(.white)
                    .shadow(color: colorScheme == .dark ? Color.white.opacity(0.2) : Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
                Spacer()
            }
            .listStyle(.plain)
            .padding()
            .sheet(isPresented: $showLogin) {
                LoginView()
            }
        }
    }
}
