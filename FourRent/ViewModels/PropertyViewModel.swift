//
//  PropertyViewModel.swift
//  FourRent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import Foundation
import Combine
import UIKit

@MainActor
class PropertyViewModel: ObservableObject {
    
    @Published var properties: [Property] = []
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var isLoading = false
    
    var availableProperties: [Property] {
        properties.filter { $0.isListed && !$0.isAssigned }
    }
    
    func landlordProperties(for landlordId: String) -> [Property] {
        properties.filter { $0.landlordId == landlordId }
    }
    
    func filteredAvailableProperties(searchText: String, maxRent: Double?) -> [Property] {
        availableProperties.filter { property in
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let matchesSearch = query.isEmpty ||
                property.title.lowercased().contains(query) ||
                property.details.lowercased().contains(query)
            let matchesRent = maxRent.map { property.rent <= $0 } ?? true
            return matchesSearch && matchesRent
        }
    }
    
    // MARK: FETCH
    
    func fetchProperties(for user: AppUser?) async {
        isLoading = true
        errorMessage = nil
        
        do {
            switch user?.role {
            case .landlord:
                guard let landlordId = user?.id else {
                    throw FirestoreServiceError.invalidRole
                }
                properties = try await FirestoreService.shared.fetchLandlordProperties(landlordId: landlordId)
            case .tenant, .guest, .none:
                properties = try await FirestoreService.shared.fetchListedProperties()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: ADD PROPERTY
    
    func addProperty(
        title: String,
        details: String,
        rent: Double,
        bedrooms: Int,
        bathrooms: Int,
        latitude: Double,
        longitude: Double,
        images: [UIImage],
        landlordId: String,
        isListed: Bool = true
    ) async {
        
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanDetails = details.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanTitle.isEmpty, !cleanDetails.isEmpty else {
            errorMessage = "Title and description are required."
            return
        }
        
        guard rent > 0 else {
            errorMessage = "Rent must be greater than 0."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            
            // SAVE IMAGES LOCALLY
            let imageNames = ImageManager.shared.saveImages(images)
            
            let newProperty = Property(
                id: UUID().uuidString,
                title: cleanTitle,
                details: cleanDetails,
                rent: rent,
                bedrooms: bedrooms,
                bathrooms: bathrooms,
                latitude: latitude,
                longitude: longitude,
                imageNames: imageNames,
                landlordId: landlordId,
                isListed: isListed,
                isAssigned: false
            )
            
            try await FirestoreService.shared.addProperty(newProperty)
            
            properties.append(newProperty)
            successMessage = "Property added."
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: UPDATE PROPERTY
    
    func updateProperty(
        property: Property,
        title: String,
        details: String,
        rent: Double,
        bedrooms: Int,
        bathrooms: Int,
        latitude: Double,
        longitude: Double,
        images: [UIImage]
    ) async {
        
        guard let index = properties.firstIndex(where: { $0.id == property.id }) else { return }
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanDetails = details.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanTitle.isEmpty, !cleanDetails.isEmpty else {
            errorMessage = "Title and description are required."
            return
        }
        
        guard rent > 0 else {
            errorMessage = "Rent must be greater than 0."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            
            var updatedProperty = property
            
            updatedProperty.title = cleanTitle
            updatedProperty.details = cleanDetails
            updatedProperty.rent = rent
            updatedProperty.bedrooms = bedrooms
            updatedProperty.bathrooms = bathrooms
            updatedProperty.latitude = latitude
            updatedProperty.longitude = longitude
            
            // UPDATE IMAGES
            let imageNames = ImageManager.shared.saveImages(images)
            updatedProperty.imageNames = imageNames
            
            try await FirestoreService.shared.updateProperty(updatedProperty)
            
            properties[index] = updatedProperty
            successMessage = "Property updated."
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func deleteProperty(_ property: Property, currentUser: AppUser?) async {
        guard currentUser?.role == .landlord, currentUser?.id == property.landlordId else {
            errorMessage = "Only the landlord who owns this property can delete it."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await FirestoreService.shared.deleteProperty(propertyId: property.id)
            properties.removeAll { $0.id == property.id }
            successMessage = "Property deleted."
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func setListing(_ property: Property, isListed: Bool, currentUser: AppUser?) async {
        guard currentUser?.role == .landlord, currentUser?.id == property.landlordId else {
            errorMessage = "Only the landlord who owns this property can update listing status."
            return
        }
        
        guard let index = properties.firstIndex(where: { $0.id == property.id }) else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await FirestoreService.shared.updatePropertyListing(propertyId: property.id, isListed: isListed)
            properties[index].isListed = isListed
            successMessage = isListed ? "Property listed." : "Property de-listed."
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
