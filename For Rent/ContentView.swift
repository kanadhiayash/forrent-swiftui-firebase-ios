//
//  ContentView.swift
//  For Rent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        
        Group {
            
            if authVM.isLoading {
                
                LoadingView()
                
            } else if let user = authVM.user {
                
                switch user.role {
                    
                case .guest:
                    GuestHomeView()
                    
                case .tenant:
                    TenantTabView()
                    
                case .landlord:
                    LandlordTabView()
                }
                
            } else {
                LoginView()
            }
        }
    }
}
