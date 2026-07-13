import XCTest
@testable import For_Rent

final class ConversationPresentationTests: XCTestCase {
    func test_renterInboxItemKeepsPropertyScopedConversationContext() {
        let item = ConversationInboxItem(
            request: request(status: .submitted, message: "Can I see it this weekend?"),
            property: property(),
            viewerRole: .tenant
        )

        XCTAssertEqual(item.id, "property-1__tenant-1__landlord-1")
        XCTAssertEqual(item.propertyTitle, "Harbourfront condo")
        XCTAssertEqual(item.participantTitle, "Property manager")
        XCTAssertEqual(item.latestPreview, "Can I see it this weekend?")
        XCTAssertEqual(item.nextActionTitle, "Continue conversation")
        XCTAssertFalse(item.isReadOnly)
        XCTAssertEqual(item.workflowCards.map(\.kind), [.inquiry])
    }

    func test_managerInboxItemSurfacesRenterAndViewingAction() {
        let item = ConversationInboxItem(
            request: request(status: .acknowledged),
            property: property(),
            viewerRole: .landlord
        )

        XCTAssertEqual(item.participantTitle, "Avery")
        XCTAssertEqual(item.nextActionTitle, "Share availability")
        XCTAssertEqual(item.workflowCards.map(\.kind), [.viewing])
    }

    func test_threadSnapshotLocksCompletionBehindStructuredOffer() {
        let snapshot = ConversationThreadSnapshot(
            request: request(status: .accepted),
            property: property(),
            viewerRole: .tenant
        )

        XCTAssertTrue(snapshot.canSendMessage)
        XCTAssertEqual(snapshot.inboxItem.nextActionTitle, "Create offer")
        XCTAssertEqual(snapshot.inboxItem.workflowCards.map(\.kind), [.offer])
        XCTAssertTrue(snapshot.inboxItem.workflowCards[0].detail.contains("Both parties must approve one offer version."))
    }

    func test_endedJourneysAreReadOnlyHistory() {
        for status in [RequestStatus.rejected, .cancelled, .expired] {
            let snapshot = ConversationThreadSnapshot(
                request: request(status: status),
                property: property(),
                viewerRole: .tenant
            )

            XCTAssertFalse(snapshot.canSendMessage)
            XCTAssertTrue(snapshot.suggestedQuestions.isEmpty)
            XCTAssertEqual(snapshot.inboxItem.nextActionTitle, "Review history")
            XCTAssertEqual(snapshot.inboxItem.workflowCards.map(\.kind), [.ended])
        }
    }

    private func request(status: RequestStatus, message: String? = nil) -> Request {
        Request(
            id: "request-1",
            propertyId: "property-1",
            landlordId: "landlord-1",
            tenantId: "tenant-1",
            tenantName: "Avery",
            tenantPhone: "555-0100",
            status: status,
            message: message
        )
    }

    private func property() -> Property {
        Property(
            id: "property-1",
            title: "Harbourfront condo",
            details: "Bright home near transit.",
            rent: 2800,
            bedrooms: 1,
            bathrooms: 1,
            latitude: 43.64,
            longitude: -79.38,
            imageNames: [],
            landlordId: "landlord-1",
            isListed: true,
            isAssigned: false,
            locationName: "Toronto, ON"
        )
    }
}
