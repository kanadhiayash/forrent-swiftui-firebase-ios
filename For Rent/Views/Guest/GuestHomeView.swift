//
//  GuestHomeView.swift
//  For Rent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import SwiftUI

struct GuestHomeView: View {
    
    @EnvironmentObject var propertyVM: PropertyViewModel
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        
        NavigationStack {
            
            Group {
                
                if propertyVM.isLoading {
                    ScrollView {
                        LazyVStack(spacing: ForRentTheme.Spacing.md) {
                            ForEach(0..<3, id: \.self) { _ in
                                ListingSkeletonView()
                            }
                        }
                        .padding()
                    }
                } else if let error = propertyVM.errorMessage {
                    ErrorView(message: error, retryAction: {
                        Task {
                            await propertyVM.fetchProperties(for: authVM.user)
                        }
                    })
                } else if propertyVM.availableProperties.isEmpty {
                    ContentUnavailableView {
                        Label("No rentals available", systemImage: "house")
                    } description: {
                        Text("Try again shortly or sign in to manage your account.")
                    }

                } else {
                    MarketplaceResultsView(
                        properties: propertyVM.availableProperties,
                        user: authVM.user ?? AppUser(
                            id: "guest",
                            email: "",
                            role: .guest,
                            firstName: "Guest",
                            lastName: "",
                            phone: "",
                            shortlisted: []
                        )
                    )
                }
            }
            .navigationTitle("Browse Rentals")
            
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        authVM.logout()
                    }
                }

                if authVM.isDemoMode {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Reset Demo") {
                            authVM.resetDemo()
                        }
                    }
                }
            }
            
            .task {
                if propertyVM.properties.isEmpty {
                    await propertyVM.fetchProperties(for: authVM.user)
                }
            }
        }
    }
}
