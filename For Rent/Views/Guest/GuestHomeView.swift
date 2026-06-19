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
                    
                    VStack {
                        ProgressView()
                        Text("Loading properties...")
                            .foregroundColor(.gray)
                    }
                    
                } else if propertyVM.availableProperties.isEmpty {
                    
                    Text("No properties available")
                        .foregroundColor(.gray)
                    
                } else {
                    
                    ScrollView {
                        
                        LazyVStack(spacing: 16) {
                            
                            ForEach(propertyVM.availableProperties) { property in
                                
                                NavigationLink(
                                    destination: PropertyDetailView(
                                        property: property,
                                        user: authVM.user ?? AppUser(
                                            id: UUID().uuidString,
                                            email: "",
                                            role: .guest,
                                            firstName: "Guest",
                                            lastName: "",
                                            phone: "",
                                            shortlisted: []
                                        )
                                    )
                                ) {
                                    PropertyCardView(property: property)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Browse Rentals")
            
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        authVM.logout()
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
