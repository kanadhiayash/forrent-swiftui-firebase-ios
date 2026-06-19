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
    
    @State private var searchText = ""
    @State private var maxRent = ""
    
    var body: some View {
        
        NavigationStack {
            
            Group {
                
                // LOADING
                if propertyVM.isLoading {
                    
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Loading properties...")
                            .foregroundColor(.gray)
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
                else {
                    let filteredProperties = propertyVM.filteredAvailableProperties(
                        searchText: searchText,
                        maxRent: Double(maxRent.trimmingCharacters(in: .whitespacesAndNewlines))
                    )
                    
                    ScrollView {
                        
                        LazyVStack(spacing: 16) {
                            VStack(spacing: 10) {
                                TextField("Search rentals", text: $searchText)
                                    .textFieldStyle(.roundedBorder)
                                    .accessibilityLabel("Search rental listings")
                                
                                TextField("Maximum rent", text: $maxRent)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(.roundedBorder)
                                    .accessibilityLabel("Filter listings by maximum rent")
                            }
                            .padding(.horizontal)
                            
                            if filteredProperties.isEmpty {
                                Text("No rentals match your filters")
                                    .foregroundColor(.gray)
                                    .padding(.top, 24)
                            }
                            
                            ForEach(filteredProperties) { property in
                                
                                if let user = authVM.user {
                                    NavigationLink {
                                        PropertyDetailView(
                                            property: property,
                                            user: user
                                        )
                                    } label: {
                                        PropertyCardView(property: property)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding()
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
}
