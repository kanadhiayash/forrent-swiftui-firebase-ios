import Foundation

struct ListingPresentation {
    let property: Property

    var priceText: String {
        "\(property.rent.toCurrency()) \(compactCadenceLabel)"
    }

    var heroSubtitle: String {
        property.resolvedLocationName
    }

    var availabilityTitle: String {
        if property.isAssigned {
            return "Assigned"
        }

        if property.isListed {
            return "Available"
        }

        return "Unavailable"
    }

    var availabilityIcon: String {
        if property.isAssigned {
            return "person.fill.checkmark"
        }

        if property.isListed {
            return "checkmark.seal.fill"
        }

        return "lock.fill"
    }

    var availabilityTone: StatusChipTone {
        if property.isAssigned {
            return .warning
        }

        if property.isListed {
            return .success
        }

        return .neutral
    }

    var compareFacts: [ListingFact] {
        var facts = [
            ListingFact(title: bedroomText, systemImage: "bed.double.fill"),
            ListingFact(title: bathroomText, systemImage: "bathtub.fill"),
            ListingFact(title: property.category.title.sentenceCased, systemImage: "square.grid.2x2.fill"),
            ListingFact(title: cadenceFactText, systemImage: "calendar")
        ]

        if let maxGuests = property.resolvedMaxGuests {
            facts.append(ListingFact(title: "Up to \(maxGuests) guests", systemImage: "person.2.fill"))
        }

        return facts
    }

    var accessibilitySummary: String {
        [
            property.title,
            priceAccessibilityText,
            property.resolvedLocationName,
            property.bedrooms == 1 ? "1 bedroom" : "\(property.bedrooms) bedrooms",
            property.bathrooms == 1 ? "1 bathroom" : "\(property.bathrooms) bathrooms",
            availabilityTitle
        ].joined(separator: ", ")
    }

    func primaryActionTitle(for role: UserRole) -> String {
        switch role {
        case .guest:
            return "Sign in to continue"
        case .tenant:
            return property.isListed && !property.isAssigned ? "Request a viewing" : "View details"
        case .landlord:
            return "Review listing"
        }
    }

    private var bedroomText: String {
        property.bedrooms == 1 ? "1 bed" : "\(property.bedrooms) beds"
    }

    private var bathroomText: String {
        property.bathrooms == 1 ? "1 bath" : "\(property.bathrooms) baths"
    }

    private var cadenceFactText: String {
        switch property.resolvedPricingCadence {
        case .monthly:
            return "Monthly"
        case .weekly:
            return "Weekly"
        case .nightly:
            return "Nightly"
        case .perStay:
            return "Per stay"
        }
    }

    private var compactCadenceLabel: String {
        switch property.resolvedPricingCadence {
        case .monthly:
            return "/mo"
        case .weekly:
            return "/wk"
        case .nightly:
            return "/night"
        case .perStay:
            return "/stay"
        }
    }

    private var priceAccessibilityText: String {
        "\(property.rent.toCurrency()) \(cadenceFactText)"
    }
}

struct ListingFact: Equatable, Identifiable {
    let title: String
    let systemImage: String

    var id: String {
        "\(systemImage)-\(title)"
    }
}

private extension String {
    var sentenceCased: String {
        let lowercasedValue = lowercased()
        guard let firstCharacter = lowercasedValue.first else {
            return lowercasedValue
        }

        return firstCharacter.uppercased() + lowercasedValue.dropFirst()
    }
}
