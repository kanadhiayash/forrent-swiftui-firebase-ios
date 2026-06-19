//
//  ForRentApp.swift
//  For Rent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import SwiftUI
import Firebase

@main
struct ForRentApp: App {
    
    @StateObject private var authVM: AuthViewModel
    @StateObject private var propertyVM: PropertyViewModel
    @StateObject private var requestVM: RequestViewModel
    @StateObject private var shortlistVM: ShortlistViewModel
    
    init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        _authVM = StateObject(wrappedValue: AuthViewModel())
        _propertyVM = StateObject(wrappedValue: PropertyViewModel())
        _requestVM = StateObject(wrappedValue: RequestViewModel())
        _shortlistVM = StateObject(wrappedValue: ShortlistViewModel())
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authVM)
                .environmentObject(propertyVM)
                .environmentObject(requestVM)
                .environmentObject(shortlistVM)
        }
    }
}
