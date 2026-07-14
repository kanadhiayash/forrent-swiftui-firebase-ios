//
//  ShortlistView.swift
//  For Rent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import SwiftUI

struct ShortlistView: View {
    
    @EnvironmentObject var shortlistVM: ShortlistViewModel
    @EnvironmentObject var propertyVM: PropertyViewModel
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        
        let savedProperties = propertyVM.availableProperties.filter {
            shortlistVM.isSaved($0.id)
        }
            
        Group {
            if let error = shortlistVM.errorMessage {
                ErrorView(message: error, dismissAction: {
                    shortlistVM.errorMessage = nil
                })
            } else if savedProperties.isEmpty {
                ContentUnavailableView {
                    Label("No saved rentals", systemImage: "heart")
                } description: {
                    Text("Save promising listings to compare them here.")
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: ForRentTheme.Spacing.md) {
                        ForEach(savedProperties) { property in
                        
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
        .navigationTitle("Saved")
        .task {
            await propertyVM.fetchProperties(for: authVM.user)
            if let user = authVM.user, user.role == .tenant {
                await shortlistVM.loadFromFirestore(userId: user.id)
            }
        }
    }
}
