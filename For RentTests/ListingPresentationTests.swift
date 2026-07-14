import XCTest
@testable import For_Rent

final class ListingPresentationTests: XCTestCase {
    func test_availableListingPresentationSummarizesMarketReadyFacts() {
        let presentation = ListingPresentation(property: availableProperty)

        XCTAssertEqual(presentation.priceText, "$2,450 /mo")
        XCTAssertEqual(presentation.availabilityTitle, "Available")
        XCTAssertEqual(presentation.availabilityIcon, "checkmark.seal.fill")
        XCTAssertEqual(presentation.availabilityTone, .success)
        XCTAssertEqual(presentation.primaryActionTitle(for: .tenant), "Request a viewing")
        XCTAssertEqual(presentation.compareFacts.map(\.title), ["2 beds", "1 bath", "Personal living", "Monthly"])
        XCTAssertEqual(presentation.heroSubtitle, "Toronto, Ontario, Canada")
    }

    func test_assignedListingPresentationPreventsViewingCTA() {
        let presentation = ListingPresentation(property: assignedProperty)

        XCTAssertEqual(presentation.availabilityTitle, "Assigned")
        XCTAssertEqual(presentation.availabilityTone, .warning)
        XCTAssertEqual(presentation.primaryActionTitle(for: .tenant), "View details")
        XCTAssertEqual(presentation.accessibilitySummary, "Parkside Apartment, $2,450 Monthly, Toronto, Ontario, Canada, 2 bedrooms, 1 bathroom, Assigned")
    }

    func test_unlistedListingPresentationUsesUnavailableState() {
        let presentation = ListingPresentation(property: unlistedProperty)

        XCTAssertEqual(presentation.availabilityTitle, "Unavailable")
        XCTAssertEqual(presentation.availabilityIcon, "lock.fill")
        XCTAssertEqual(presentation.availabilityTone, .neutral)
        XCTAssertEqual(presentation.primaryActionTitle(for: .guest), "Sign in to continue")
    }
}

private extension ListingPresentationTests {
    var availableProperty: Property {
        property(isListed: true, isAssigned: false)
    }

    var assignedProperty: Property {
        property(isListed: true, isAssigned: true)
    }

    var unlistedProperty: Property {
        property(isListed: false, isAssigned: false)
    }

    func property(isListed: Bool, isAssigned: Bool) -> Property {
        Property(
            id: "listing-1",
            title: "Parkside Apartment",
            details: "Two-bedroom apartment near transit",
            rent: 2_450,
            bedrooms: 2,
            bathrooms: 1,
            latitude: 43.65,
            longitude: -79.38,
            imageNames: [],
            landlordId: "landlord-1",
            isListed: isListed,
            isAssigned: isAssigned,
            category: .personalLiving,
            locationName: "Toronto, Ontario, Canada",
            pricingCadence: .monthly,
            amenities: ["Laundry", "Bike storage"]
        )
    }
}
