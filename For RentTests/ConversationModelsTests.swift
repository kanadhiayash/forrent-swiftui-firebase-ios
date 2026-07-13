import XCTest
@testable import For_Rent

final class ConversationModelsTests: XCTestCase {
    func test_propertyScopedConversationIdIsStableAndSafeForFirestore() {
        let id = Conversation.propertyScopedId(
            propertyId: "property/42",
            renterId: "renter/abc",
            managerId: "manager/xyz"
        )

        XCTAssertEqual(id, "property_42__renter_abc__manager_xyz")
    }

    func test_messageTrimsBodyAndRejectsEmptyText() throws {
        let message = try Message(
            id: "message-1",
            conversationId: "conversation-1",
            senderId: "renter-1",
            senderRole: .renter,
            body: "  Is Saturday afternoon available?  ",
            createdAt: referenceDate
        )

        XCTAssertEqual(message.body, "Is Saturday afternoon available?")
        XCTAssertThrowsError(
            try Message(
                id: "message-2",
                conversationId: "conversation-1",
                senderId: "renter-1",
                senderRole: .renter,
                body: "   ",
                createdAt: referenceDate
            )
        )
    }

    func test_workflowEventsReferenceRecordsInsteadOfEmbeddingThem() {
        let event = ConversationEvent.viewingReserved(
            id: "event-1",
            conversationId: "conversation-1",
            actorId: "renter-1",
            viewingId: "viewing-1",
            createdAt: referenceDate
        )

        XCTAssertEqual(event.kind, .viewingReserved)
        XCTAssertEqual(event.reference.collection, "viewings")
        XCTAssertEqual(event.reference.id, "viewing-1")
        XCTAssertFalse(event.completesJourney)
    }

    func test_mutualDecisionIsTheOnlyCompletionEvent() {
        let event = ConversationEvent.mutualDecisionCreated(
            id: "event-2",
            conversationId: "conversation-1",
            actorId: "system",
            decisionId: "decision-1",
            createdAt: referenceDate
        )

        XCTAssertTrue(event.completesJourney)
    }
}

private extension ConversationModelsTests {
    var referenceDate: Date {
        Date(timeIntervalSince1970: 1_800_000_000)
    }
}
