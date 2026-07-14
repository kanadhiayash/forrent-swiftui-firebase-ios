//
//  Property.swift
//  For Rent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import Foundation

struct Property: Identifiable, Codable {

    var id: String

    var title: String
    var details: String

    var rent: Double

    var bedrooms: Int
    var bathrooms: Int

    var latitude: Double
    var longitude: Double

    var imageNames: [String]

    var landlordId: String

    var isListed: Bool
    var isAssigned: Bool

    var category: RentalCategory
    var locationName: String?
    var pricingCadence: PricingCadence?
    var amenities: [String]?
    var maxGuests: Int?

    var resolvedLocationName: String {
        Self.cleanedOptionalString(locationName) ?? "Location selected on map"
    }

    var resolvedPricingCadence: PricingCadence {
        guard let pricingCadence, category.allowedPricingCadences.contains(pricingCadence) else {
            return category.defaultPricingCadence
        }

        return pricingCadence
    }

    var resolvedAmenities: [String] {
        Self.cleanedAmenities(from: amenities ?? [])
    }

    var resolvedMaxGuests: Int? {
        guard category.supportsGuestCount else { return nil }
        guard let maxGuests, maxGuests > 0 else { return nil }
        return maxGuests
    }

    init(
        id: String,
        title: String,
        details: String,
        rent: Double,
        bedrooms: Int,
        bathrooms: Int,
        latitude: Double,
        longitude: Double,
        imageNames: [String],
        landlordId: String,
        isListed: Bool,
        isAssigned: Bool,
        category: RentalCategory = .personalLiving,
        locationName: String? = nil,
        pricingCadence: PricingCadence? = nil,
        amenities: [String]? = nil,
        maxGuests: Int? = nil
    ) {
        self.id = id
        self.title = title
        self.details = details
        self.rent = rent
        self.bedrooms = bedrooms
        self.bathrooms = bathrooms
        self.latitude = latitude
        self.longitude = longitude
        self.imageNames = imageNames
        self.landlordId = landlordId
        self.isListed = isListed
        self.isAssigned = isAssigned
        self.category = category
        self.locationName = Self.cleanedOptionalString(locationName)
        self.pricingCadence = category.allowedPricingCadences.contains(pricingCadence ?? category.defaultPricingCadence) ? pricingCadence : category.defaultPricingCadence
        let normalizedAmenities = Self.cleanedAmenities(from: amenities ?? [])
        self.amenities = normalizedAmenities.isEmpty ? nil : normalizedAmenities
        self.maxGuests = category.supportsGuestCount ? maxGuests : nil
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case details
        case rent
        case bedrooms
        case bathrooms
        case latitude
        case longitude
        case imageNames
        case landlordId
        case isListed
        case isAssigned
        case category
        case locationName
        case pricingCadence
        case amenities
        case maxGuests
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        details = try container.decode(String.self, forKey: .details)
        rent = try container.decode(Double.self, forKey: .rent)
        bedrooms = try container.decode(Int.self, forKey: .bedrooms)
        bathrooms = try container.decode(Int.self, forKey: .bathrooms)
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
        imageNames = try container.decode([String].self, forKey: .imageNames)
        landlordId = try container.decode(String.self, forKey: .landlordId)
        isListed = try container.decode(Bool.self, forKey: .isListed)
        isAssigned = try container.decode(Bool.self, forKey: .isAssigned)

        category = try container.decodeIfPresent(RentalCategory.self, forKey: .category) ?? .personalLiving
        locationName = Self.cleanedOptionalString(try container.decodeIfPresent(String.self, forKey: .locationName))
        pricingCadence = try container.decodeIfPresent(PricingCadence.self, forKey: .pricingCadence)

        if let amenityArray = try container.decodeIfPresent([String].self, forKey: .amenities) {
            let normalizedAmenities = Self.cleanedAmenities(from: amenityArray)
            amenities = normalizedAmenities.isEmpty ? nil : normalizedAmenities
        } else if let amenityString = try container.decodeIfPresent(String.self, forKey: .amenities) {
            let normalizedAmenities = Self.cleanedAmenities(from: amenityString.split(separator: ",").map(String.init))
            amenities = normalizedAmenities.isEmpty ? nil : normalizedAmenities
        } else {
            amenities = nil
        }

        if let decodedMaxGuests = try container.decodeIfPresent(Int.self, forKey: .maxGuests),
           decodedMaxGuests > 0,
           category.supportsGuestCount {
            maxGuests = decodedMaxGuests
        } else {
            maxGuests = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(details, forKey: .details)
        try container.encode(rent, forKey: .rent)
        try container.encode(bedrooms, forKey: .bedrooms)
        try container.encode(bathrooms, forKey: .bathrooms)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(imageNames, forKey: .imageNames)
        try container.encode(landlordId, forKey: .landlordId)
        try container.encode(isListed, forKey: .isListed)
        try container.encode(isAssigned, forKey: .isAssigned)
        try container.encode(category, forKey: .category)
        try container.encodeIfPresent(Self.cleanedOptionalString(locationName), forKey: .locationName)
        try container.encode(resolvedPricingCadence, forKey: .pricingCadence)

        let normalizedAmenities = resolvedAmenities
        if !normalizedAmenities.isEmpty {
            try container.encode(normalizedAmenities, forKey: .amenities)
        }

        try container.encodeIfPresent(resolvedMaxGuests, forKey: .maxGuests)
    }
}

private extension Property {
    static func cleanedOptionalString(_ value: String?) -> String? {
        guard let value else { return nil }

        let cleanedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return cleanedValue.isEmpty ? nil : cleanedValue
    }

    static func cleanedAmenities(from values: [String]) -> [String] {
        values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}
