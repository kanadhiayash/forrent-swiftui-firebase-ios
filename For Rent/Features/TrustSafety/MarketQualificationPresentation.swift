import Foundation

struct MarketQualificationPresentationItem: Equatable, Identifiable {
    let id: String
    let area: MarketQualificationArea
    let title: String
    let statusTitle: String
    let evidenceSummary: String?
}

struct MarketQualificationPresentationSnapshot: Equatable {
    let title: String
    let statusTitle: String
    let summary: String
    let verifiedRequiredCount: Int
    let requiredCount: Int
    let progressValue: Double
    let primaryActionTitle: String
    let items: [MarketQualificationPresentationItem]

    init(checklist: MarketQualificationChecklist) {
        let requiredItems = checklist.items.filter(\.isRequired)
        let verifiedItems = requiredItems.filter { item in
            item.status == .verified && item.evidence != nil
        }

        title = "Market qualification"
        statusTitle = checklist.isReadyForLaunch ? "Ready for owner review" : "Not ready for launch"
        summary = checklist.statusSummary
        verifiedRequiredCount = verifiedItems.count
        requiredCount = requiredItems.count
        progressValue = requiredItems.isEmpty
            ? 1
            : Double(verifiedItems.count) / Double(requiredItems.count)
        primaryActionTitle = checklist.isReadyForLaunch
            ? "Prepare release evidence"
            : "Keep qualifying"
        items = checklist.items.map(Self.present)
    }

    private static func present(_ item: MarketQualificationItem) -> MarketQualificationPresentationItem {
        MarketQualificationPresentationItem(
            id: item.id,
            area: item.area,
            title: item.title,
            statusTitle: item.status == .verified && item.evidence != nil
                ? "Verified"
                : "Needs evidence",
            evidenceSummary: item.evidence.map(format)
        )
    }

    private static func format(_ evidence: MarketQualificationEvidence) -> String {
        switch evidence {
        case .manualReview(let note):
            "Manual review: \(note)"
        case .command(let name, let result):
            "Command: \(name), \(result)"
        }
    }
}
