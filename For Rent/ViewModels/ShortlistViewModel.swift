//
//  ShortlistViewModel.swift
//  For Rent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import Foundation
import Combine

@MainActor
class ShortlistViewModel: ObservableObject {
    private let environment: AppEnvironment
    
    @Published var shortlistedIds: Set<String> = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private let keyPrefix = "shortlisted_properties"
    private var activeUserId: String?

    init(environment: AppEnvironment? = nil) {
        self.environment = environment ?? .firebase
    }
    
    func toggle(propertyId: String, userId: String?) async {
        errorMessage = nil

        guard let userId else {
            errorMessage = "Sign in as a renter to save properties."
            return
        }

        if let demoSession = environment.demoSession {
            activeUserId = userId
            shortlistedIds = demoSession.toggleShortlist(propertyId: propertyId, userId: userId)
            return
        }

        activate(userId: userId)
        
        if shortlistedIds.contains(propertyId) {
            shortlistedIds.remove(propertyId)
            
            do {
                try await FirestoreService.shared.removeFromShortlist(
                    userId: userId,
                    propertyId: propertyId
                )
            } catch {
                shortlistedIds.insert(propertyId)
                errorMessage = error.localizedDescription
            }
            
        } else {
            shortlistedIds.insert(propertyId)
            
            do {
                try await FirestoreService.shared.updateShortlist(
                    userId: userId,
                    propertyId: propertyId
                )
            } catch {
                shortlistedIds.remove(propertyId)
                errorMessage = error.localizedDescription
            }
        }
        
        saveLocal()
    }
    
    func loadFromFirestore(userId: String) async {
        if let demoSession = environment.demoSession {
            activeUserId = userId
            shortlistedIds = demoSession.shortlistedIds(for: userId)
            errorMessage = nil
            return
        }

        activate(userId: userId)
        isLoading = true
        errorMessage = nil
        
        do {
            let propertyIds = try await FirestoreService.shared.fetchShortlistedPropertyIds(userId: userId)
            shortlistedIds = Set(propertyIds)
            saveLocal()
        } catch {
            errorMessage = "Unable to load saved properties."
        }
        
        isLoading = false
    }
    
    func isSaved(_ id: String) -> Bool {
        shortlistedIds.contains(id)
    }
    
    private func saveLocal() {
        guard let activeUserId else { return }
        UserDefaults.standard.set(Array(shortlistedIds), forKey: key(for: activeUserId))
    }
    
    private func activate(userId: String) {
        guard activeUserId != userId else { return }
        activeUserId = userId
        loadLocal(userId: userId)
    }

    private func loadLocal(userId: String) {
        let saved = UserDefaults.standard.stringArray(forKey: key(for: userId)) ?? []
        shortlistedIds = Set(saved)
    }

    private func key(for userId: String) -> String {
        "\(keyPrefix)_\(userId)"
    }
}
