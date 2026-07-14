//
//  TenantTabView.swift
//  For Rent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import SwiftUI

struct TenantTabView: View {
    
    var body: some View {
        
        TabView {
            
            // MARK: Discover
            NavigationStack {
                TenantHomeView()
                    .navigationTitle("Discover")
            }
            .tabItem {
                Label("Discover", systemImage: "house")
            }
            
            // MARK: Shortlist
            NavigationStack {
                ShortlistView()
                    .navigationTitle("Saved")
            }
            .tabItem {
                Label("Saved", systemImage: "heart")
            }
            
            // MARK: Journey
            NavigationStack {
                JourneyView()
                    .navigationTitle("Journey")
            }
            .tabItem {
                Label("Journey", systemImage: "map")
            }
            
            // MARK: Account
            NavigationStack {
                AccountView()
            }
            .tabItem {
                Label("Account", systemImage: "person.crop.circle")
            }
        }
    }
}
