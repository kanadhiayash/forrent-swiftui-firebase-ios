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
        
        NavigationStack {
            
            let savedProperties = propertyVM.availableProperties.filter {
                shortlistVM.isSaved($0.id)
            }
            
            if savedProperties.isEmpty {
                
                Text("No saved properties")
                    .foregroundColor(.gray)
                
            } else {
                
                List {
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
                        }
                    }
                    .onDelete { indexSet in
                        
                        for index in indexSet {
                            let property = savedProperties[index]
                            
                            Task {
                                await shortlistVM.toggle(
                                    propertyId: property.id,
                                    userId: authVM.user?.id
                                )
                            }
                        }
                    }
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
        .showError($shortlistVM.errorMessage)
    }
}
