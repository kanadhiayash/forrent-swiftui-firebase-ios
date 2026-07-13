import XCTest
@testable import For_Rent

final class AgreementPreparationPresentationTests: XCTestCase {
    func test_mutuallyAcceptedOfferBuildsOntarioPreparationSnapshot() throws {
        let offer = try mutuallyAcceptedOffer()

        let snapshot = try AgreementPreparationSnapshot(
            offer: offer,
            jurisdiction: .ontario,
            now: referenceDate.addingTimeInterval(300)
        )

        XCTAssertEqual(snapshot.statusTitle, "Agreement preparation")
        XCTAssertEqual(snapshot.approvedVersionTitle, "Approved offer version 2")
        XCTAssertEqual(snapshot.monthlyRentTitle, "$2,475 CAD")
        XCTAssertTrue(snapshot.legalNotice.contains("Ontario standard lease"))
        XCTAssertTrue(snapshot.legalNotice.contains("does not add clauses"))
        XCTAssertEqual(snapshot.confirmedTerms.first, AgreementTermSummary(title: "Move-in", value: "Jan 29, 2027"))
        XCTAssertTrue(snapshot.requiredDocuments.contains("Mutually approved offer summary"))
        XCTAssertEqual(snapshot.primaryActionTitle, "Prepare draft package")
    }

    func test_unacceptedOfferReturnsBlockedSnapshot() {
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

        let snapshot = AgreementPreparationSnapshot.blocked(offer: offer)

        XCTAssertEqual(snapshot.statusTitle, "Waiting for mutual approval")
        XCTAssertEqual(snapshot.primaryActionTitle, "Return to offer")
        XCTAssertTrue(snapshot.legalNotice.contains("both approval timestamps"))
    }

    func test_nonOntarioJurisdictionRequiresLegalReview() throws {
        let offer = try mutuallyAcceptedOffer()

        XCTAssertThrowsError(try AgreementPreparationSnapshot(
            offer: offer,
            jurisdiction: .legalReviewRequired,
            now: referenceDate.addingTimeInterval(300)
        )) { error in
            XCTAssertEqual(error as? AgreementDraftError, .unsupportedJurisdiction)
        }
    }
}

private extension AgreementPreparationPresentationTests {
    var referenceDate: Date {
        Date(timeIntervalSince1970: 1_800_000_000)
    }

    func mutuallyAcceptedOffer() throws -> RentalOffer {
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
        return offer
    }

    func terms(monthlyRent: Decimal) -> RentalOfferTerms {
        RentalOfferTerms(
            monthlyRent: monthlyRent,
            desiredMoveInDate: referenceDate.addingTimeInterval(14 * 24 * 60 * 60),
            leaseLengthMonths: 12,
            includesParking: true,
            includesStorage: true,
            includesUtilities: false,
            includesFurnishings: false,
            occupancyCount: 2,
            conditions: ["Subject to document review"],
            expiresAt: referenceDate.addingTimeInterval(48 * 60 * 60),
            note: "Flexible on move-in week"
        )
    }
}
