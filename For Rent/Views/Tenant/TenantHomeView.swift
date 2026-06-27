//
//  TenantHomeView.swift
//  For Rent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import SwiftUI

struct TenantHomeView: View {
    
    @EnvironmentObject var propertyVM: PropertyViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var requestVM: RequestViewModel
    
    var body: some View {
        
        Group {
                
                // LOADING
                if propertyVM.isLoading {
                    ScrollView {
                        LazyVStack(spacing: ForRentTheme.Spacing.md) {
                            ForEach(0..<3, id: \.self) { _ in
                                ListingSkeletonView()
                            }
                        }
                    }
                }
                
                // ERROR
                else if let error = propertyVM.errorMessage {
                    
                    ErrorView(
                        message: error,
                        retryAction: {
                            Task {
                                await propertyVM.fetchProperties(for: authVM.user)
                            }
                        }
                    )
                }
                
                // EMPTY
                else if propertyVM.availableProperties.isEmpty {
                    
                    VStack(spacing: 12) {
                        Image(systemName: "house")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        
                        Text("No properties available")
                            .foregroundColor(.gray)
                    }
                }
                
                // DATA
                else if let user = authVM.user {
                    MarketplaceResultsView(
                        properties: propertyVM.availableProperties,
                        user: user
                    )
                } else {
                    ContentUnavailableView {
                        Label("Sign in required", systemImage: "person.crop.circle.badge.exclamationmark")
                    } description: {
                        Text("Choose a renter account to browse and save rentals.")
                    }
                }
            }
            .navigationTitle("Explore")
            .task {
                if propertyVM.properties.isEmpty {
                    await propertyVM.fetchProperties(for: authVM.user)
                }
                requestVM.startListening(for: authVM.user)
            }
        }
}
