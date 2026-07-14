//
//  ForRentApp.swift
//  For Rent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import SwiftUI
import Firebase
import FirebaseAppCheck

@main
struct ForRentApp: App {
    private let appEnvironment: AppEnvironment
    
    @StateObject private var authVM: AuthViewModel
    @StateObject private var propertyVM: PropertyViewModel
    @StateObject private var requestVM: RequestViewModel
    @StateObject private var shortlistVM: ShortlistViewModel
    @StateObject private var feedbackCenter: FeedbackCenter
    
    init() {
        let resolvedEnvironment: AppEnvironment

        do {
            resolvedEnvironment = try AppEnvironment.detect(bundle: .main)
        } catch {
            fatalError("Unable to load the app environment. \(error.localizedDescription)")
        }

        appEnvironment = resolvedEnvironment

        if resolvedEnvironment.isFirebase, FirebaseApp.app() == nil {
#if DEBUG
            AppCheck.setAppCheckProviderFactory(AppCheckDebugProviderFactory())
#else
            AppCheck.setAppCheckProviderFactory(AppAttestProviderFactory())
#endif
            FirebaseApp.configure()
        }
        
        _authVM = StateObject(wrappedValue: AuthViewModel(environment: resolvedEnvironment))
        _propertyVM = StateObject(wrappedValue: PropertyViewModel(environment: resolvedEnvironment))
        _requestVM = StateObject(wrappedValue: RequestViewModel(environment: resolvedEnvironment))
        _shortlistVM = StateObject(wrappedValue: ShortlistViewModel(environment: resolvedEnvironment))
        _feedbackCenter = StateObject(wrappedValue: FeedbackCenter())
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authVM)
                .environmentObject(propertyVM)
                .environmentObject(requestVM)
                .environmentObject(shortlistVM)
                .environmentObject(feedbackCenter)
        }
    }
}
