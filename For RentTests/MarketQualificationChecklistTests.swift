import XCTest
@testable import For_Rent

final class MarketQualificationChecklistTests: XCTestCase {
    func test_defaultChecklistCoversAllMarketQualificationAreas() {
        let checklist = MarketQualificationChecklist.defaultReleaseGate()

        XCTAssertEqual(checklist.items.map(\.area), [
            .localization,
            .accessibility,
            .performance,
            .securityPrivacy,
            .moderationOperations,
            .testFlightEvidence,
            .monitoring,
            .productionFirebase
        ])
        XCTAssertFalse(checklist.isReadyForLaunch)
    }

    func test_requiredGateNeedsEvidenceBeforeLaunchReadiness() {
        var checklist = MarketQualificationChecklist.defaultReleaseGate()

        checklist.recordEvidence(
            for: .localization,
            evidence: .manualReview(note: "English string catalog reviewed.")
        )

        XCTAssertFalse(checklist.isReadyForLaunch)
        XCTAssertEqual(checklist.items[0].status, .verified)
        XCTAssertEqual(checklist.items[1].status, .notStarted)
    }

    func test_launchReadinessRequiresEveryRequiredGate() {
        var checklist = MarketQualificationChecklist.defaultReleaseGate()

        for area in MarketQualificationArea.allCases {
            checklist.recordEvidence(
                for: area,
                evidence: .manualReview(note: "Verified \(area.rawValue).")
            )
        }

        XCTAssertTrue(checklist.isReadyForLaunch)
        XCTAssertEqual(checklist.statusSummary, "8 of 8 required gates verified")
    }
}
