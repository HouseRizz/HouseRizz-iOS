//
//  LoginView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 17/06/24.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel = Authentication()
    @State var isSignupView = false
    
    private func signInWithEmailPassword() {
        Task {
            await viewModel.signInWithEmailPassword()
        }
    }
    
    var body: some View {
        VStack(spacing:10){
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }
            
            HStack {
                Image(systemName: "at")
                TextField("Email", text: $viewModel.email)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .submitLabel(.next)
                
            }
            .padding(.vertical, 6)
            .background(Divider(), alignment: .bottom)
            .padding(.bottom, 4)
            
            HStack {
                Image(systemName: "lock")
                SecureField("Password", text: $viewModel.password)
                    .submitLabel(.go)
            }
            .padding(.vertical, 6)
            .background(Divider(), alignment: .bottom)
            .padding(.bottom, 8)
            
            if viewModel.authenticationState != .authenticating {
                HRAuthenticationButton(label: "Login") {
                    signInWithEmailPassword()
                }
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
            }
            
            HStack {
                VStack { Divider() }
                Text("or")
                VStack { Divider() }
            }
            
            HRAuthenticationButton(label: "Sign up with Email", iconName: "envelope.fill") {
                isSignupView.toggle()
            }
        }
        .padding()
        .sheet(isPresented: $isSignupView) {
            SignupView()
        }
    }
}

#Preview {
    LoginView()
}
