//
//  PropertyViewModel.swift
//  For Rent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import Foundation
import Combine
import UIKit

@MainActor
class PropertyViewModel: ObservableObject {
    private let environment: AppEnvironment
    
    @Published var properties: [Property] = []
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var isLoading = false
    
    var availableProperties: [Property] {
        properties.filter { $0.isListed && !$0.isAssigned }
    }

    init(environment: AppEnvironment? = nil) {
        self.environment = environment ?? .firebase
    }
    
    func landlordProperties(for landlordId: String) -> [Property] {
        properties.filter { $0.landlordId == landlordId }
    }
    
    func filteredAvailableProperties(searchText: String, maxRent: Double?) -> [Property] {
        availableProperties.filter { property in
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let matchesSearch = query.isEmpty ||
                property.title.lowercased().contains(query) ||
                property.details.lowercased().contains(query) ||
                property.resolvedLocationName.lowercased().contains(query) ||
                property.category.title.lowercased().contains(query) ||
                property.resolvedAmenities.joined(separator: " ").lowercased().contains(query)
            let matchesRent = maxRent.map { property.rent <= $0 } ?? true
            return matchesSearch && matchesRent
        }
    }
    
    // MARK: FETCH
    
    func fetchProperties(for user: AppUser?) async {
        isLoading = true
        errorMessage = nil

        if let demoSession = environment.demoSession {
            properties = demoSession.properties(for: user)
            isLoading = false
            return
        }
        
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
        category: RentalCategory,
        locationName: String?,
        pricingCadence: PricingCadence,
        amenities: [String],
        maxGuests: Int?,
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

        guard let resolvedLocationName = normalizedLocationName(from: locationName) else {
            errorMessage = "Add a display location for renters."
            return
        }

        let normalizedPricingCadence = normalizedPricingCadence(
            pricingCadence,
            for: category
        )
        let normalizedAmenities = normalizedAmenities(from: amenities)
        let normalizedMaxGuests = normalizedMaxGuests(maxGuests, for: category)

        if category.supportsGuestCount, normalizedMaxGuests == nil {
            errorMessage = "Add a guest limit for this listing type."
            return
        }
        
        isLoading = true
        errorMessage = nil
        var uploadedImageNames: [String] = []
        
        do {
            let propertyId = UUID().uuidString
            let imageNames: [String]

            if environment.isDemo {
                imageNames = ImageManager.shared.saveImages(images)
            } else {
                imageNames = try await ListingMediaService.shared.upload(
                    images: images,
                    landlordId: landlordId,
                    listingId: propertyId
                )
                uploadedImageNames = imageNames
            }
            
            var newProperty = Property(
                id: propertyId,
                title: cleanTitle,
                details: cleanDetails,
                rent: rent,
                bedrooms: bedrooms,
                bathrooms: bathrooms,
                latitude: latitude,
                longitude: longitude,
                imageNames: imageNames,
                landlordId: landlordId,
                isListed: environment.isDemo ? isListed : false,
                isAssigned: false,
                category: category,
                locationName: resolvedLocationName,
                pricingCadence: normalizedPricingCadence,
                amenities: normalizedAmenities,
                maxGuests: normalizedMaxGuests
            )

            if let demoSession = environment.demoSession {
                demoSession.addProperty(newProperty)
                properties = demoSession.properties(for: demoSession.user(id: landlordId))
                successMessage = "Property added."
                isLoading = false
                return
            }
            
            try await FirestoreService.shared.addProperty(newProperty)
            if isListed {
                try await FirestoreService.shared.updatePropertyListing(
                    propertyId: newProperty.id,
                    isListed: true
                )
                newProperty.isListed = true
            }
            
            properties.append(newProperty)
            successMessage = "Property added."
            
        } catch {
            if !uploadedImageNames.isEmpty {
                await ListingMediaService.shared.delete(paths: uploadedImageNames)
            }
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
        category: RentalCategory,
        locationName: String?,
        pricingCadence: PricingCadence,
        amenities: [String],
        maxGuests: Int?,
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

        guard let resolvedLocationName = normalizedLocationName(from: locationName) else {
            errorMessage = "Add a display location for renters."
            return
        }

        let normalizedPricingCadence = normalizedPricingCadence(
            pricingCadence,
            for: category
        )
        let normalizedAmenities = normalizedAmenities(from: amenities)
        let normalizedMaxGuests = normalizedMaxGuests(maxGuests, for: category)

        if category.supportsGuestCount, normalizedMaxGuests == nil {
            errorMessage = "Add a guest limit for this listing type."
            return
        }
        
        isLoading = true
        errorMessage = nil
        var uploadedImageNames: [String] = []
        
        do {
            
            var updatedProperty = property
            
            updatedProperty.title = cleanTitle
            updatedProperty.details = cleanDetails
            updatedProperty.rent = rent
            updatedProperty.bedrooms = bedrooms
            updatedProperty.bathrooms = bathrooms
            updatedProperty.category = category
            updatedProperty.locationName = resolvedLocationName
            updatedProperty.pricingCadence = normalizedPricingCadence
            updatedProperty.amenities = normalizedAmenities.isEmpty ? nil : normalizedAmenities
            updatedProperty.maxGuests = normalizedMaxGuests
            updatedProperty.latitude = latitude
            updatedProperty.longitude = longitude
            
            if let demoSession = environment.demoSession {
                updatedProperty.imageNames = ImageManager.shared.saveImages(images)
                demoSession.updateProperty(updatedProperty)
                properties = demoSession.properties(for: demoSession.user(id: updatedProperty.landlordId))
                successMessage = "Property updated."
                isLoading = false
                return
            }

            let previousImageNames = updatedProperty.imageNames
            if !images.isEmpty {
                updatedProperty.imageNames = try await ListingMediaService.shared.upload(
                    images: images,
                    landlordId: updatedProperty.landlordId,
                    listingId: updatedProperty.id
                )
                uploadedImageNames = updatedProperty.imageNames
            }
            
            try await FirestoreService.shared.updateProperty(updatedProperty)
            if !images.isEmpty {
                await ListingMediaService.shared.delete(paths: previousImageNames.filter {
                    $0.hasPrefix("listing-media/")
                })
            }
            
            properties[index] = updatedProperty
            successMessage = "Property updated."
            
        } catch {
            if !uploadedImageNames.isEmpty {
                await ListingMediaService.shared.delete(paths: uploadedImageNames)
            }
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
            if let demoSession = environment.demoSession {
                demoSession.deleteProperty(propertyId: property.id)
                properties = demoSession.properties(for: currentUser)
                successMessage = "Property deleted."
                isLoading = false
                return
            }

            try await FirestoreService.shared.deleteProperty(propertyId: property.id)
            await ListingMediaService.shared.delete(paths: property.imageNames.filter {
                $0.hasPrefix("listing-media/")
            })
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
            if let demoSession = environment.demoSession {
                demoSession.updatePropertyListing(propertyId: property.id, isListed: isListed)
                properties = demoSession.properties(for: currentUser)
                successMessage = isListed ? "Property listed." : "Property de-listed."
                isLoading = false
                return
            }

            try await FirestoreService.shared.updatePropertyListing(propertyId: property.id, isListed: isListed)
            properties[index].isListed = isListed
            successMessage = isListed ? "Property listed." : "Property de-listed."
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }

    private func normalizedLocationName(from value: String?) -> String? {
        let trimmedValue = value?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let trimmedValue, !trimmedValue.isEmpty else {
            return nil
        }

        return trimmedValue
    }

    private func normalizedPricingCadence(
        _ pricingCadence: PricingCadence,
        for category: RentalCategory
    ) -> PricingCadence {
        category.allowedPricingCadences.contains(pricingCadence) ? pricingCadence : category.defaultPricingCadence
    }

    private func normalizedAmenities(from amenities: [String]) -> [String] {
        amenities
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private func normalizedMaxGuests(_ maxGuests: Int?, for category: RentalCategory) -> Int? {
        guard category.supportsGuestCount else { return nil }
        guard let maxGuests, maxGuests > 0 else { return nil }
        return maxGuests
    }
}
