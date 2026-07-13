import XCTest
@testable import For_Rent

final class JourneyTimelineTests: XCTestCase {
    func test_submittedInquiryStartsConversationJourney() {
        let snapshot = JourneyTimelineSnapshot(
            request: makeRequest(status: .submitted),
            property: makeProperty()
        )

        XCTAssertEqual(snapshot.propertyTitle, "Harbourfront Studio")
        XCTAssertEqual(snapshot.currentStage, .conversation)
        XCTAssertEqual(snapshot.primaryActionTitle, "Open conversation")
        XCTAssertFalse(snapshot.isEnded)
        XCTAssertFalse(snapshot.isCompletionEligible)
    }

    func test_viewingScheduledPromotesViewingAsNextStep() {
        let snapshot = JourneyTimelineSnapshot(
            request: makeRequest(status: .viewingScheduled),
            property: makeProperty()
        )

        XCTAssertEqual(snapshot.currentStage, .viewing)
        XCTAssertEqual(snapshot.primaryActionTitle, "View booking details")
        XCTAssertTrue(snapshot.steps.contains { $0.stage == .viewing && $0.state == .active })
        XCTAssertFalse(snapshot.isCompletionEligible)
    }

    func test_acceptedInquiryRequiresStructuredOfferBeforeCompletion() {
        let snapshot = JourneyTimelineSnapshot(
            request: makeRequest(status: .accepted),
            property: makeProperty()
        )

        XCTAssertEqual(snapshot.currentStage, .offer)
        XCTAssertEqual(snapshot.primaryActionTitle, "Create structured offer")
        XCTAssertFalse(snapshot.isEnded)
        XCTAssertFalse(snapshot.isCompletionEligible)
        XCTAssertTrue(snapshot.steps.contains { $0.stage == .mutualApproval && $0.state == .locked })
    }

    func test_rejectedCancelledAndExpiredJourneysAreEnded() {
        for status in [RequestStatus.rejected, .cancelled, .expired] {
            let snapshot = JourneyTimelineSnapshot(
                request: makeRequest(status: status),
                property: makeProperty()
            )

            XCTAssertTrue(snapshot.isEnded)
            XCTAssertEqual(snapshot.primaryActionTitle, "Review summary")
            XCTAssertEqual(snapshot.currentStage, .ended)
        }
    }

    private func makeRequest(status: RequestStatus) -> Request {
        Request(
            id: "tenant-1_property-1",
            propertyId: "property-1",
            landlordId: "landlord-1",
            tenantId: "tenant-1",
            tenantName: "Avery",
            tenantPhone: "555-0100",
            status: status
        )
    }

    private func makeProperty() -> Property {
        Property(
            id: "property-1",
            title: "Harbourfront Studio",
            details: "Bright studio near transit.",
            rent: 2400,
            bedrooms: 1,
            bathrooms: 1,
            latitude: 43.64,
            longitude: -79.38,
            imageNames: [],
            landlordId: "landlord-1",
            isListed: true,
            isAssigned: false,
            locationName: "Toronto, Ontario, Canada"
        )
    }
}
