//
//  LoginView.swift
//  FourRent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var authVM: AuthViewModel
    
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        
        NavigationStack {
            
            VStack(spacing: 24) {
                
                Spacer()
                
                Text("For Rent")
                    .font(.largeTitle.bold())
                
                Text("Find rentals. Manage requests. Move with clarity.")
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 16) {
                    
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    
                    SecureField("Password", text: $password)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    
                    Button {
                        Task {
                            await authVM.login(
                                email: email,
                                password: password
                            )
                        }
                    } label: {
                        Text("Login")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(authVM.isLoading)
                    .accessibilityLabel("Log in to For Rent")
                }
                .padding(.horizontal)
                
                NavigationLink("Create Account") {
                    SignUpView()
                }
                
                Button("Continue as Guest") {
                    authVM.continueAsGuest()
                }
                .foregroundColor(.gray)
                .accessibilityHint("Browse available properties without an account.")
                
                Spacer()
            }
            .padding()
            .overlay {
                if let error = authVM.errorMessage {
                    ErrorView(
                        message: error,
                        dismissAction: {
                            authVM.errorMessage = nil
                        }
                    )
                }
            }
            .overlay {
                if authVM.isLoading {
                    LoadingView()
                }
            }
        }
    }
}
