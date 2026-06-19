//
//  LandlordTabView.swift
//  For Rent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import SwiftUI

struct LandlordTabView: View {
    
    var body: some View {
        
        TabView {
            
            // MARK: My Properties
            NavigationStack {
                MyPropertiesView()
                    .navigationTitle("My Properties")
            }
            .tabItem {
                Label("Properties", systemImage: "building.2")
            }
            
            // MARK: ADD PROPERTY (REPLACES SAVED)
            NavigationStack {
                AddPropertyView()
                    .navigationTitle("Add Property")
            }
            .tabItem {
                Label("Add", systemImage: "plus.circle.fill")
            }
            
            // MARK: REQUESTS
            NavigationStack {
                RequestsView()
                    .navigationTitle("Requests")
            }
            .tabItem {
                Label("Requests", systemImage: "bubble.left.and.bubble.right")
            }
            
            // MARK: PROFILE
            NavigationStack {
                ProfileView()
                    .navigationTitle("Profile")
            }
            .tabItem {
                Label("Profile", systemImage: "person")
            }
        }
        .tint(.black)
    }
}
