//
//  RootView.swift
//  For Rent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import SwiftUI

struct RootView: View {
    
    @StateObject var authVM = AuthViewModel()
    @StateObject var propertyVM = PropertyViewModel()
    
    var body: some View {
        
        NavigationStack {
            
            if let user = authVM.user {
                
                switch user.role {
                case .tenant:
                    TenantHomeView()
                case .landlord:
                    LandlordHomeView()
                case .guest:
                    GuestHomeView()
                }
                
            } else {
                
                VStack(spacing: 20) {
                    
                    Text("For Rent")
                        .font(.largeTitle)
                        .bold()
                    
                    NavigationLink("Login") {
                        LoginView()
                    }
                    
                    NavigationLink("Sign Up") {
                        SignUpView()
                    }
                    
                    Button("Browse as Guest") {
                        authVM.continueAsGuest()
                    }
                }
            }
        }
        .environmentObject(authVM)
        .environmentObject(propertyVM)
    }
}
