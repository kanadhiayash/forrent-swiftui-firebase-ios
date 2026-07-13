import XCTest
@testable import For_Rent

final class PostViewingDecisionModelsTests: XCTestCase {
    func test_promptIsEligibleOnlyAfterCompletedViewingGracePeriod() {
        let completedViewing = viewing(status: .completed)
        let beforeGrace = PostViewingPromptEligibility.canPrompt(
            viewing: completedViewing,
            at: referenceDate.addingTimeInterval(34 * 60),
            graceMinutes: 5
        )
        let afterGrace = PostViewingPromptEligibility.canPrompt(
            viewing: completedViewing,
            at: referenceDate.addingTimeInterval(35 * 60),
            graceMinutes: 5
        )

        XCTAssertFalse(beforeGrace)
        XCTAssertTrue(afterGrace)
    }

    func test_cancelledAndMissedViewingsNeverAdvanceToOffer() {
        XCTAssertFalse(PostViewingPromptEligibility.canPrompt(
            viewing: viewing(status: .cancelled),
            at: referenceDate.addingTimeInterval(2 * 60 * 60),
            graceMinutes: 5
        ))
        XCTAssertFalse(PostViewingPromptEligibility.canPrompt(
            viewing: viewing(status: .missed),
            at: referenceDate.addingTimeInterval(2 * 60 * 60),
            graceMinutes: 5
        ))
    }

    func test_yesDecisionOpensStructuredOfferComposer() {
        let decision = PostViewingDecision(
            id: "decision-1",
            viewingId: "viewing-1",
            conversationId: "conversation-1",
            propertyId: "property-1",
            renterId: "renter-1",
            choice: .yes,
            feedback: "Great layout",
            createdAt: referenceDate
        )

        XCTAssertEqual(decision.continuation, .openOfferComposer)
        XCTAssertTrue(decision.notifiesManagerAsPositiveSignal)
    }

    func test_noAndNotSureDecisionsKeepDifferentJourneyOutcomes() {
        let noDecision = PostViewingDecision(
            id: "decision-2",
            viewingId: "viewing-1",
            conversationId: "conversation-1",
            propertyId: "property-1",
            renterId: "renter-1",
            choice: .no,
            feedback: nil,
            createdAt: referenceDate
        )
        let unsureDecision = PostViewingDecision(
            id: "decision-3",
            viewingId: "viewing-1",
            conversationId: "conversation-1",
            propertyId: "property-1",
            renterId: "renter-1",
            choice: .notSure,
            feedback: nil,
            createdAt: referenceDate
        )

        XCTAssertEqual(noDecision.continuation, .archiveReadOnly)
        XCTAssertEqual(unsureDecision.continuation, .oneReminderWindow)
        XCTAssertFalse(unsureDecision.notifiesManagerAsPositiveSignal)
    }
}

private extension PostViewingDecisionModelsTests {
    var referenceDate: Date {
        Date(timeIntervalSince1970: 1_800_000_000)
    }

    func viewing(status: ViewingStatus) -> Viewing {
        Viewing(
            id: "viewing-1",
            propertyId: "property-1",
            conversationId: "conversation-1",
            renterId: "renter-1",
            managerId: "manager-1",
            startAt: referenceDate,
            endAt: referenceDate.addingTimeInterval(30 * 60),
            timezoneIdentifier: "America/Toronto",
            status: status
        )
    }
}
