import Foundation

struct ListingV2: Identifiable, Codable, Equatable {
    struct Money: Codable, Equatable {
        let amountMinor: Int
        let currencyCode: String

        init(amountMinor: Int, currencyCode: String = "CAD") {
            self.amountMinor = amountMinor
            self.currencyCode = currencyCode
        }
    }

    struct PublicLocation: Codable, Equatable {
        let city: String
        let provinceOrTerritory: String
        let countryCode: String
        let neighbourhood: String?
    }

    struct PrivateAddress: Codable, Equatable {
        let street: String
        let postalCode: String
    }

    enum Lifecycle: String, Codable, CaseIterable {
        case draft
        case published
        case paused
        case rented
        case archived
    }

    let schemaVersion: Int
    let id: String
    var title: String
    var summary: String
    var price: Money
    var pricingCadence: PricingCadence
    var bedrooms: Int
    var bathrooms: Int
    var publicLocation: PublicLocation
    var privateAddress: PrivateAddress?
    var availabilityDate: Date?
    var leaseTermMonths: Int?
    var amenities: [String]
    var policies: [String]
    var mediaReferences: [String]
    var landlordId: String
    var lifecycle: Lifecycle
    var createdAt: Date?
    var updatedAt: Date?

    init(legacy property: Property) {
        let locationParts = property.resolvedLocationName
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        schemaVersion = 2
        id = property.id
        title = property.title
        summary = property.details
        price = Money(amountMinor: Int((property.rent * 100).rounded()))
        pricingCadence = property.resolvedPricingCadence
        bedrooms = property.bedrooms
        bathrooms = property.bathrooms
        publicLocation = PublicLocation(
            city: locationParts.first ?? property.resolvedLocationName,
            provinceOrTerritory: locationParts.count > 1 ? locationParts[1] : "",
            countryCode: "CA",
            neighbourhood: nil
        )
        privateAddress = nil
        availabilityDate = nil
        leaseTermMonths = property.category == .personalLiving ? 12 : nil
        amenities = property.resolvedAmenities
        policies = []
        mediaReferences = property.imageNames
        landlordId = property.landlordId

        if property.isAssigned {
            lifecycle = .rented
        } else if property.isListed {
            lifecycle = .published
        } else {
            lifecycle = .paused
        }

        createdAt = nil
        updatedAt = nil
    }
}
