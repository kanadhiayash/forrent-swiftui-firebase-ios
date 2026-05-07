//
//  MyPropertiesView.swift
//  FourRent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import SwiftUI

struct MyPropertiesView: View {
    
    @EnvironmentObject var propertyVM: PropertyViewModel
    @EnvironmentObject var authVM: AuthViewModel
    
    @State private var propertyToDelete: Property?
    
    var body: some View {
        Group {
            if propertyVM.isLoading {
                LoadingView()
            } else if let error = propertyVM.errorMessage {
                ErrorView(message: error, retryAction: {
                    Task {
                        await propertyVM.fetchProperties(for: authVM.user)
                    }
                })
            } else if let user = authVM.user {
                let myProperties = propertyVM.landlordProperties(for: user.id)
                
                if myProperties.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "building.2")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("No properties yet")
                            .font(.headline)
                        Text("Add your first rental to start receiving tenant requests.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(myProperties) { property in
                            NavigationLink {
                                UpdatePropertyView(property: property)
                            } label: {
                                PropertyCardView(property: property)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    propertyToDelete = property
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    Task {
                                        await propertyVM.setListing(
                                            property,
                                            isListed: !property.isListed,
                                            currentUser: authVM.user
                                        )
                                    }
                                } label: {
                                    Label(
                                        property.isListed ? "De-list" : "List",
                                        systemImage: property.isListed ? "eye.slash" : "eye"
                                    )
                                }
                                .tint(property.isListed ? .orange : .green)
                            }
                        }
                    }
                }
            } else {
                Text("Sign in as a landlord to manage properties.")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        .task {
            await propertyVM.fetchProperties(for: authVM.user)
        }
        .alert("Delete property?", isPresented: Binding(
            get: { propertyToDelete != nil },
            set: { if !$0 { propertyToDelete = nil } }
        )) {
            Button("Delete", role: .destructive) {
                guard let propertyToDelete else { return }
                
                Task {
                    await propertyVM.deleteProperty(
                        propertyToDelete,
                        currentUser: authVM.user
                    )
                    self.propertyToDelete = nil
                }
            }
            
            Button("Cancel", role: .cancel) {
                propertyToDelete = nil
            }
        } message: {
            Text("This removes the property document from Firestore and cannot be undone.")
        }
    }
}
