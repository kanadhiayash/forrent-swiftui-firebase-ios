import XCTest
@testable import For_Rent

final class OfferModelsTests: XCTestCase {
    func test_submittedOfferStoresStructuredTermsAndProposerApproval() {
        let offer = RentalOffer.submitted(
            id: "offer-1",
            propertyId: "property-1",
            conversationId: "conversation-1",
            renterId: "renter-1",
            managerId: "manager-1",
            proposer: .renter,
            terms: terms(monthlyRent: 2_400),
            createdAt: referenceDate
        )

        XCTAssertEqual(offer.status, .submitted)
        XCTAssertEqual(offer.latestVersion.terms.monthlyRent, 2_400)
        XCTAssertEqual(offer.latestVersion.versionNumber, 1)
        XCTAssertEqual(offer.latestVersion.renterApprovalAt, referenceDate)
        XCTAssertNil(offer.latestVersion.managerApprovalAt)
    }

    func test_counterofferCreatesNewVersionAndResetsOtherPartyApproval() throws {
        var offer = RentalOffer.submitted(
            id: "offer-1",
            propertyId: "property-1",
            conversationId: "conversation-1",
            renterId: "renter-1",
            managerId: "manager-1",
            proposer: .renter,
            terms: terms(monthlyRent: 2_400),
            createdAt: referenceDate
        )

        try offer.counter(
            proposer: .manager,
            terms: terms(monthlyRent: 2_475),
            createdAt: referenceDate.addingTimeInterval(60)
        )

        XCTAssertEqual(offer.status, .countered)
        XCTAssertEqual(offer.versions.map(\.versionNumber), [1, 2])
        XCTAssertEqual(offer.versions[0].terms.monthlyRent, 2_400)
        XCTAssertEqual(offer.latestVersion.terms.monthlyRent, 2_475)
        XCTAssertNil(offer.latestVersion.renterApprovalAt)
        XCTAssertEqual(offer.latestVersion.managerApprovalAt, referenceDate.addingTimeInterval(60))
    }

    func test_mutualAcceptanceRequiresBothPartiesOnLatestVersion() throws {
        var offer = RentalOffer.submitted(
            id: "offer-1",
            propertyId: "property-1",
            conversationId: "conversation-1",
            renterId: "renter-1",
            managerId: "manager-1",
            proposer: .renter,
            terms: terms(monthlyRent: 2_400),
            createdAt: referenceDate
        )

        try offer.counter(
            proposer: .manager,
            terms: terms(monthlyRent: 2_475),
            createdAt: referenceDate.addingTimeInterval(60)
        )
        try offer.approveLatestVersion(
            party: .renter,
            approvedAt: referenceDate.addingTimeInterval(120)
        )

        XCTAssertEqual(offer.status, .mutuallyAccepted)
        XCTAssertEqual(offer.latestVersion.renterApprovalAt, referenceDate.addingTimeInterval(120))
        XCTAssertEqual(offer.latestVersion.managerApprovalAt, referenceDate.addingTimeInterval(60))
        XCTAssertTrue(offer.latestVersion.isMutuallyApproved)
    }

    func test_expiredOfferCannotBeApproved() throws {
        var offer = RentalOffer.submitted(
            id: "offer-1",
            propertyId: "property-1",
            conversationId: "conversation-1",
            renterId: "renter-1",
            managerId: "manager-1",
            proposer: .renter,
            terms: terms(monthlyRent: 2_400, expiresAt: referenceDate.addingTimeInterval(-60)),
            createdAt: referenceDate
        )

        try offer.expire(at: referenceDate)

        XCTAssertThrowsError(try offer.approveLatestVersion(
            party: .manager,
            approvedAt: referenceDate
        ))
        XCTAssertEqual(offer.status, .expired)
    }
}

private extension OfferModelsTests {
    var referenceDate: Date {
        Date(timeIntervalSince1970: 1_800_000_000)
    }

    func terms(monthlyRent: Decimal, expiresAt: Date? = nil) -> RentalOfferTerms {
        RentalOfferTerms(
            monthlyRent: monthlyRent,
            desiredMoveInDate: referenceDate.addingTimeInterval(14 * 24 * 60 * 60),
            leaseLengthMonths: 12,
            includesParking: true,
            includesStorage: false,
            includesUtilities: false,
            includesFurnishings: false,
            occupancyCount: 2,
            conditions: ["Subject to document review"],
            expiresAt: expiresAt ?? referenceDate.addingTimeInterval(48 * 60 * 60),
            note: "Flexible on move-in week"
        )
    }
}
