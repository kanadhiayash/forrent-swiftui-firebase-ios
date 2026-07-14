import XCTest
@testable import For_Rent

final class MarketplaceModelsTests: XCTestCase {
    func test_listingV2MigratesLegacyPropertyWithoutExposingPrivateAddress() {
        let property = Property(
            id: "legacy-1",
            title: "Parkside Apartment",
            details: "Two-bedroom apartment",
            rent: 2450,
            bedrooms: 2,
            bathrooms: 1,
            latitude: 43.65,
            longitude: -79.38,
            imageNames: [],
            landlordId: "landlord-1",
            isListed: true,
            isAssigned: false,
            locationName: "Toronto, Ontario, Canada"
        )

        let listing = ListingV2(legacy: property)

        XCTAssertEqual(listing.schemaVersion, 2)
        XCTAssertEqual(listing.price.amountMinor, 245_000)
        XCTAssertEqual(listing.lifecycle, .published)
        XCTAssertEqual(listing.publicLocation.city, "Toronto")
        XCTAssertNil(listing.privateAddress)
    }

    func test_inquiryAllowsOnlyDocumentedStateTransitions() {
        XCTAssertTrue(InquiryStatus.submitted.canTransition(to: .acknowledged))
        XCTAssertTrue(InquiryStatus.acknowledged.canTransition(to: .viewingScheduled))
        XCTAssertTrue(InquiryStatus.viewingScheduled.canTransition(to: .accepted))
        XCTAssertFalse(InquiryStatus.rejected.canTransition(to: .accepted))
        XCTAssertFalse(InquiryStatus.cancelled.canTransition(to: .acknowledged))
    }

    func test_requestStatusMatchesInquiryStateMachine() {
        XCTAssertTrue(RequestStatus.submitted.canTransition(to: .acknowledged))
        XCTAssertTrue(RequestStatus.acknowledged.canTransition(to: .viewingScheduled))
        XCTAssertTrue(RequestStatus.viewingScheduled.canTransition(to: .accepted))
        XCTAssertTrue(RequestStatus.submitted.canTransition(to: .cancelled))
        XCTAssertFalse(RequestStatus.rejected.canTransition(to: .accepted))
        XCTAssertFalse(RequestStatus.expired.canTransition(to: .acknowledged))
    }
}
