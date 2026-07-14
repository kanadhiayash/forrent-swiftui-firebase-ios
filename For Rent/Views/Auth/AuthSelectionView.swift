//
//  AuthSelectionView.swift
//  For Rent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import SwiftUI

struct AuthSelectionView: View {
    
    @State private var showLogin = false
    @State private var showSignup = false
    
    var body: some View {
        
        VStack(spacing: 20) {
            
            Text("For Rent")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Button("Login") {
                showLogin = true
            }
            .buttonStyle(.borderedProminent)
            
            Button("Sign Up") {
                showSignup = true
            }
            .buttonStyle(.bordered)
        }
        .navigationDestination(isPresented: $showLogin) {
            LoginView()
        }
        .navigationDestination(isPresented: $showSignup) {
            SignUpView()
        }
    }
}
