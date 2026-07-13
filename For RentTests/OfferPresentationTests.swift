import XCTest
@testable import For_Rent

final class OfferPresentationTests: XCTestCase {
    func test_draftBuildsStructuredTermsWithParsedConditions() throws {
        var draft = StructuredOfferDraft(monthlyRentText: "2450")
        draft.moveInDate = referenceDate.addingTimeInterval(14 * 24 * 60 * 60)
        draft.leaseLengthMonths = 12
        draft.includesParking = true
        draft.includesStorage = true
        draft.occupancyCount = 2
        draft.conditionsText = "Subject to document review, Professional cleaning"
        draft.note = "Flexible on move-in week"

        let terms = try draft.makeTerms(now: referenceDate)

        XCTAssertEqual(terms.monthlyRent, 2_450)
        XCTAssertEqual(terms.leaseLengthMonths, 12)
        XCTAssertTrue(terms.includesParking)
        XCTAssertTrue(terms.includesStorage)
        XCTAssertEqual(terms.occupancyCount, 2)
        XCTAssertEqual(terms.conditions, ["Subject to document review", "Professional cleaning"])
        XCTAssertEqual(terms.expiresAt, referenceDate.addingTimeInterval(48 * 60 * 60))
    }

    func test_draftRejectsInvalidRentAndOccupancy() {
        var draft = StructuredOfferDraft(monthlyRentText: "abc")
        XCTAssertThrowsError(try draft.makeTerms(now: referenceDate)) { error in
            XCTAssertEqual(error as? StructuredOfferDraft.ValidationError, .invalidMonthlyRent)
        }

        draft = StructuredOfferDraft(monthlyRentText: "2400")
        draft.occupancyCount = 0
        XCTAssertThrowsError(try draft.makeTerms(now: referenceDate)) { error in
            XCTAssertEqual(error as? StructuredOfferDraft.ValidationError, .invalidOccupancy)
        }
    }

    func test_reviewSnapshotShowsLatestVersionAndApprovalState() throws {
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

        let snapshot = OfferReviewSnapshot(offer: offer)

        XCTAssertEqual(snapshot.versionTitle, "Version 2")
        XCTAssertEqual(snapshot.monthlyRentTitle, "$2,475 CAD")
        XCTAssertEqual(snapshot.approvalSummary, "Manager approved. Waiting for renter approval.")
        XCTAssertEqual(snapshot.statusTitle, "Countered")
    }
}

private extension OfferPresentationTests {
    var referenceDate: Date {
        Date(timeIntervalSince1970: 1_800_000_000)
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
            note: nil
        )
    }
}
