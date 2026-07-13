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
            
            // MARK: CALENDAR
            NavigationStack {
                ViewingCalendarView()
            }
            .tabItem {
                Label("Calendar", systemImage: "calendar")
            }
            
            // MARK: INBOX
            NavigationStack {
                RequestsView()
            }
            .tabItem {
                Label("Inbox", systemImage: "bubble.left.and.bubble.right")
            }
            
            // MARK: ACCOUNT
            NavigationStack {
                AccountView()
            }
            .tabItem {
                Label("Account", systemImage: "person.crop.circle")
            }
        }
    }
}
