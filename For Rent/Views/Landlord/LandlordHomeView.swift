//
//  LandlordHomeView.swift
//  For Rent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import SwiftUI

struct LandlordHomeView: View {
    
    @EnvironmentObject var propertyVM: PropertyViewModel
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        
        NavigationStack {
            
            VStack {
                
                NavigationLink("Add Property") {
                    AddPropertyView()
                }
                .buttonStyle(.borderedProminent)
                .padding()
                
                ScrollView {
                    
                    ForEach(propertyVM.landlordProperties(for: authVM.user?.id ?? "")) { property in
                        
                        NavigationLink(destination: UpdatePropertyView(property: property)) {
                            PropertyCardView(property: property)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("My Properties")
            .task {
                await propertyVM.fetchProperties(for: authVM.user)
            }
        }
    }
}
