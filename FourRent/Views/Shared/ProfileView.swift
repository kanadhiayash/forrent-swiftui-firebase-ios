//
//  ProfileView.swift
//  FourRent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        
        VStack(spacing: 20) {
            
            Text(authVM.user?.firstName ?? "User")
                .font(.title)
                .bold()
            
            Text(authVM.user?.email ?? "")
                .foregroundColor(.gray)
            
            Text(authVM.user?.role.rawValue.capitalized ?? "")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            NavigationLink("Edit Profile") {
                EditProfileView()
            }
            
            Button(action: {
                authVM.logout()
            }) {
                Text("Logout")
                    .foregroundColor(.red)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Profile")
        .alert("Success", isPresented: Binding(
            get: { authVM.successMessage != nil },
            set: { if !$0 { authVM.successMessage = nil } }
        )) {
            Button("OK", role: .cancel) {
                authVM.successMessage = nil
            }
        } message: {
            Text(authVM.successMessage ?? "")
        }
    }
}
