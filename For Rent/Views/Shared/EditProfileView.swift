//
//  EditProfileView.swift
//  For Rent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import SwiftUI

struct EditProfileView: View {
    
    @EnvironmentObject var authVM: AuthViewModel
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var phone = ""
    
    var body: some View {
        
        Form {
            
            Section(header: Text("Personal Info")) {
                
                TextField("First Name", text: $firstName)
                TextField("Last Name", text: $lastName)
                TextField("Phone", text: $phone)
            }
            
            Button("Update Profile") {
                Task {
                    await authVM.updateProfile(
                        firstName: firstName,
                        lastName: lastName,
                        phone: phone
                    )
                }
            }
            .disabled(authVM.isLoading)
        }
        .onAppear {
            firstName = authVM.user?.firstName ?? ""
            lastName = authVM.user?.lastName ?? ""
            phone = authVM.user?.phone ?? ""
        }
        .navigationTitle("Edit Profile")
        .overlay {
            if authVM.isLoading {
                LoadingView()
            }
        }
        .showError($authVM.errorMessage)
    }
}
