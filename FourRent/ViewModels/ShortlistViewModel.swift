//
//  ShortlistViewModel.swift
//  FourRent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import Foundation
import Combine

@MainActor
class ShortlistViewModel: ObservableObject {
    
    @Published var shortlistedIds: Set<String> = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private let key = "shortlisted_properties"
    
    init() {
        loadLocal()
    }
    
    func toggle(propertyId: String, userId: String?) async {
        errorMessage = nil
        
        if shortlistedIds.contains(propertyId) {
            shortlistedIds.remove(propertyId)
            
            if let userId {
                do {
                    try await FirestoreService.shared.removeFromShortlist(
                        userId: userId,
                        propertyId: propertyId
                    )
                } catch {
                    shortlistedIds.insert(propertyId)
                    errorMessage = error.localizedDescription
                }
            }
            
        } else {
            shortlistedIds.insert(propertyId)
            
            if let userId {
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
        }
        
        saveLocal()
    }
    
    func loadFromFirestore(userId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let user = try await FirestoreService.shared.fetchUser(uid: userId)
            shortlistedIds = Set(user.shortlisted)
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
        UserDefaults.standard.set(Array(shortlistedIds), forKey: key)
    }
    
    private func loadLocal() {
        let saved = UserDefaults.standard.stringArray(forKey: key) ?? []
        shortlistedIds = Set(saved)
    }
}
