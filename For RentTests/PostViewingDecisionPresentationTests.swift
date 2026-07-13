import XCTest
@testable import For_Rent

final class PostViewingDecisionPresentationTests: XCTestCase {
    func test_completedViewingAfterGraceBuildsActionableCheckIn() {
        let snapshot = PostViewingDecisionSnapshot(
            viewing: viewing(status: .completed),
            property: property(),
            now: referenceDate.addingTimeInterval(40 * 60),
            graceMinutes: 5
        )

        XCTAssertTrue(snapshot.isPromptReady)
        XCTAssertEqual(snapshot.propertyTitle, "Harbourfront Studio")
        XCTAssertEqual(snapshot.promptTitle, "Still interested in this home?")
        XCTAssertEqual(snapshot.options.map(\.choice), [.yes, .notSure, .no])
    }

    func test_missedAndCancelledViewingsCannotAdvanceToOffer() {
        for status in [ViewingStatus.missed, .cancelled] {
            let snapshot = PostViewingDecisionSnapshot(
                viewing: viewing(status: status),
                property: property(),
                now: referenceDate.addingTimeInterval(40 * 60),
                graceMinutes: 5
            )

            XCTAssertFalse(snapshot.isPromptReady)
            XCTAssertEqual(snapshot.promptTitle, "Check-in unavailable")
            XCTAssertFalse(snapshot.options.contains { $0.choice == .yes })
        }
    }

    func test_decisionOutcomesStayExplicit() {
        XCTAssertEqual(PostViewingDecisionOption(choice: .yes).continuationTitle, "Start structured offer")
        XCTAssertEqual(PostViewingDecisionOption(choice: .notSure).continuationTitle, "Set one reminder")
        XCTAssertEqual(PostViewingDecisionOption(choice: .no).continuationTitle, "End this listing journey")
    }
}

private extension PostViewingDecisionPresentationTests {
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

    func property() -> Property {
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
            landlordId: "manager-1",
            isListed: true,
            isAssigned: false,
            locationName: "Toronto, Ontario, Canada"
        )
    }
}
