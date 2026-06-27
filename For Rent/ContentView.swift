//
//  ContentView.swift
//  For Rent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var propertyVM: PropertyViewModel
    @EnvironmentObject var requestVM: RequestViewModel
    @EnvironmentObject var feedbackCenter: FeedbackCenter
    
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
        .tint(ForRentTheme.Colors.action)
        .feedbackHost()
        .onChange(of: authVM.successMessage) { _, message in
            publishSuccess(message) { authVM.successMessage = nil }
        }
        .onChange(of: propertyVM.successMessage) { _, message in
            publishSuccess(message) { propertyVM.successMessage = nil }
        }
        .onChange(of: requestVM.successMessage) { _, message in
            publishSuccess(message) { requestVM.successMessage = nil }
        }
        .sheet(item: pendingPropertyBinding) { property in
            if let user = authVM.user {
                NavigationStack {
                    PropertyDetailView(property: property, user: user)
                }
            }
        }
    }

    private func publishSuccess(_ message: String?, clear: () -> Void) {
        guard let message else { return }
        feedbackCenter.show(.success(message))
        clear()
    }

    private var pendingPropertyBinding: Binding<Property?> {
        Binding {
            guard authVM.user?.role == .tenant else { return nil }
            return authVM.pendingProtectedProperty
        } set: { property in
            if property == nil {
                authVM.pendingProtectedProperty = nil
            }
        }
    }
}
