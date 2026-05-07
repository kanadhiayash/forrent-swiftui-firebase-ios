//
//  TenantTabView.swift
//  FourRent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import SwiftUI

struct TenantTabView: View {
    
    var body: some View {
        
        TabView {
            
            // MARK: Explore
            NavigationStack {
                TenantHomeView()
                    .navigationTitle("Explore")
            }
            .tabItem {
                Label("Explore", systemImage: "house")
            }
            
            // MARK: Shortlist
            NavigationStack {
                ShortlistView()
                    .navigationTitle("Saved")
            }
            .tabItem {
                Label("Saved", systemImage: "heart")
            }
            
            // MARK: Requests
            NavigationStack {
                RequestsView()
                    .navigationTitle("Requests")
            }
            .tabItem {
                Label("Requests", systemImage: "bubble.left.and.bubble.right")
            }
            
            // MARK: Profile
            NavigationStack {
                ProfileView()
                    .navigationTitle("Profile")
            }
            .tabItem {
                Label("Profile", systemImage: "person")
            }
        }
    }
}
