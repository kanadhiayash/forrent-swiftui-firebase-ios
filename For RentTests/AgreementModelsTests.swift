import XCTest
@testable import For_Rent

final class AgreementModelsTests: XCTestCase {
    func test_ontarioDraftMapsOnlyMutuallyApprovedTerms() throws {
        let offer = try mutuallyAcceptedOffer()

        let draft = try AgreementDraft.prepare(
            id: "agreement-1",
            offer: offer,
            jurisdiction: .ontario,
            createdAt: referenceDate.addingTimeInterval(180)
        )

        XCTAssertEqual(draft.status, .preparation)
        XCTAssertEqual(draft.jurisdiction, .ontario)
        XCTAssertEqual(draft.offerId, "offer-1")
        XCTAssertEqual(draft.approvedOfferVersionId, offer.latestVersion.id)
        XCTAssertEqual(draft.fieldMap.monthlyRent, 2_475)
        XCTAssertEqual(draft.fieldMap.leaseLengthMonths, 12)
        XCTAssertEqual(draft.fieldMap.includesParking, true)
        XCTAssertEqual(draft.fieldMap.occupancyCount, 2)
        XCTAssertTrue(draft.legalNotice.contains("Ontario standard lease"))
    }

    func test_draftCannotBePreparedBeforeMutualApproval() {
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

        XCTAssertThrowsError(try AgreementDraft.prepare(
            id: "agreement-1",
            offer: offer,
            jurisdiction: .ontario,
            createdAt: referenceDate
        ))
    }

    func test_otherJurisdictionsRequireLegalReviewBeforeTemplateGeneration() throws {
        let offer = try mutuallyAcceptedOffer()

        XCTAssertThrowsError(try AgreementDraft.prepare(
            id: "agreement-1",
            offer: offer,
            jurisdiction: .legalReviewRequired,
            createdAt: referenceDate
        ))
    }

    func test_correctionRequestKeepsApprovedTermsImmutable() throws {
        var draft = try AgreementDraft.prepare(
            id: "agreement-1",
            offer: try mutuallyAcceptedOffer(),
            jurisdiction: .ontario,
            createdAt: referenceDate
        )

        try draft.requestCorrection(
            id: "revision-1",
            requestedBy: .renter,
            note: "Please confirm the parking line.",
            createdAt: referenceDate.addingTimeInterval(240)
        )

        XCTAssertEqual(draft.status, .correctionRequested)
        XCTAssertEqual(draft.revisions.count, 1)
        XCTAssertEqual(draft.revisions[0].note, "Please confirm the parking line.")
        XCTAssertEqual(draft.fieldMap.monthlyRent, 2_475)
    }
}

private extension AgreementModelsTests {
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
            includesStorage: false,
            includesUtilities: false,
            includesFurnishings: false,
            occupancyCount: 2,
            conditions: ["Subject to document review"],
            expiresAt: referenceDate.addingTimeInterval(48 * 60 * 60),
            note: "Flexible on move-in week"
        )
    }
}
