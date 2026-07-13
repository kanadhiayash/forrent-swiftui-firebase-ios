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
