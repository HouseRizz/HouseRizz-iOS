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
        ZStack {
            Image("authscreen")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Spacer()
                    Text("Skip")
                        .underline()
                        .bold()
                        .foregroundStyle(Color.white)
                        .padding()
                        .onTapGesture {
                            signInAnonymously()
                        }
                        .padding(.top, 15)
                }
                                
                VStack(spacing: 10) {
                    SignInWithAppleButton(.continue) { request in
                        viewModel.handleSignInWithAppleRequest(request)
                    } onCompletion: { result in
                        viewModel.handleSignInWithAppleCompletion(result)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 45)
                    .cornerRadius(20)
                    .signInWithAppleButtonStyle(.white)
                    .shadow(color: colorScheme == .dark ? Color.white.opacity(0.2) : Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                    
                    HRAuthenticationButton(label: "Continue with Google", iconImage: Image("google")) { signInWithGoogle() }
                    
                    HRAuthenticationButton(label: "Continue with Email", iconName: "envelope.fill") { showLogin.toggle() }
                }
                .padding(.top, 80)
                .sheet(isPresented: $showLogin) { LoginView() }
                
                Spacer()
            }
            .padding(.horizontal)
        }
    }
}
