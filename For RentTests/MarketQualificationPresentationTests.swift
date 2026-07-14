import XCTest
@testable import For_Rent

final class MarketQualificationPresentationTests: XCTestCase {
    func test_defaultSnapshotShowsBlockedLaunchReadiness() {
        let snapshot = MarketQualificationPresentationSnapshot(
            checklist: .defaultReleaseGate()
        )

        XCTAssertEqual(snapshot.title, "Market qualification")
        XCTAssertEqual(snapshot.statusTitle, "Not ready for launch")
        XCTAssertEqual(snapshot.summary, "0 of 8 required gates verified")
        XCTAssertEqual(snapshot.verifiedRequiredCount, 0)
        XCTAssertEqual(snapshot.requiredCount, 8)
        XCTAssertEqual(snapshot.progressValue, 0)
        XCTAssertEqual(snapshot.primaryActionTitle, "Keep qualifying")
        XCTAssertTrue(snapshot.items.allSatisfy { $0.statusTitle == "Needs evidence" })
    }

    func test_verifiedEvidenceFormatsCommandAndManualReviewDetails() {
        var checklist = MarketQualificationChecklist.defaultReleaseGate()
        checklist.recordEvidence(
            for: .accessibility,
            evidence: .manualReview(note: "VoiceOver, Dynamic Type, Increase Contrast, and Reduce Motion reviewed on device.")
        )
        checklist.recordEvidence(
            for: .securityPrivacy,
            evidence: .command(name: "npm run scan:secrets", result: "passed")
        )

        let snapshot = MarketQualificationPresentationSnapshot(checklist: checklist)

        XCTAssertEqual(snapshot.summary, "2 of 8 required gates verified")
        XCTAssertEqual(snapshot.progressValue, 0.25)
        XCTAssertEqual(snapshot.item(for: .accessibility)?.statusTitle, "Verified")
        XCTAssertEqual(
            snapshot.item(for: .accessibility)?.evidenceSummary,
            "Manual review: VoiceOver, Dynamic Type, Increase Contrast, and Reduce Motion reviewed on device."
        )
        XCTAssertEqual(
            snapshot.item(for: .securityPrivacy)?.evidenceSummary,
            "Command: npm run scan:secrets, passed"
        )
    }

    func test_readySnapshotRequiresEveryRequiredGateWithEvidence() {
        var checklist = MarketQualificationChecklist.defaultReleaseGate()

        for area in MarketQualificationArea.allCases {
            checklist.recordEvidence(
                for: area,
                evidence: .manualReview(note: "Verified \(area.rawValue).")
            )
        }

        let snapshot = MarketQualificationPresentationSnapshot(checklist: checklist)

        XCTAssertEqual(snapshot.statusTitle, "Ready for owner review")
        XCTAssertEqual(snapshot.summary, "8 of 8 required gates verified")
        XCTAssertEqual(snapshot.progressValue, 1)
        XCTAssertEqual(snapshot.primaryActionTitle, "Prepare release evidence")
    }
}

private extension MarketQualificationPresentationSnapshot {
    func item(for area: MarketQualificationArea) -> MarketQualificationPresentationItem? {
        items.first { $0.area == area }
    }
}
