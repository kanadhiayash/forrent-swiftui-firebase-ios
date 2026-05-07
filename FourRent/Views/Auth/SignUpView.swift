//
//  SignUpView.swift
//  FourRent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import SwiftUI

struct SignUpView: View {
    
    @EnvironmentObject var authVM: AuthViewModel
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var phone = ""
    @State private var role: UserRole = .tenant
    
    var body: some View {
        
        ScrollView {
            
            VStack(spacing: 20) {
                
                Text("Create Account")
                    .font(.largeTitle.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Group {
                    
                    TextField("First Name", text: $firstName)
                    
                    TextField("Last Name", text: $lastName)
                    
                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
                    
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $password)
                    
                    SecureField("Confirm Password", text: $confirmPassword)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                // ROLE SELECTOR
                VStack(alignment: .leading, spacing: 8) {
                    Text("I am a")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Picker("", selection: $role) {
                        Text("Tenant").tag(UserRole.tenant)
                        Text("Landlord").tag(UserRole.landlord)
                    }
                    .pickerStyle(.segmented)
                }
                
                // REGISTER BUTTON
                Button {
                    Task {
                        await authVM.register(
                            email: email,
                            password: password,
                            confirmPassword: confirmPassword,
                            firstName: firstName,
                            lastName: lastName,
                            phone: phone,
                            role: role
                        )
                    }
                } label: {
                    Text("Create Account")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(authVM.isLoading)
                .padding(.top, 10)
                
            }
            .padding()
        }
        .navigationTitle("For Rent Sign Up")
        .navigationBarTitleDisplayMode(.inline)
        
        // LOADING
        .overlay {
            if authVM.isLoading {
                LoadingView()
            }
        }
        
        // ERROR
        .alert("Error", isPresented: .constant(authVM.errorMessage != nil)) {
            Button("OK") {
                authVM.errorMessage = nil
            }
        } message: {
            Text(authVM.errorMessage ?? "")
        }
    }
}
