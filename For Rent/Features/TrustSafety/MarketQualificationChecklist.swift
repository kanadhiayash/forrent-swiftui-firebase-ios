import Foundation

enum MarketQualificationArea: String, CaseIterable, Codable, Equatable {
    case localization
    case accessibility
    case performance
    case securityPrivacy = "security_privacy"
    case moderationOperations = "moderation_operations"
    case testFlightEvidence = "testflight_evidence"
    case monitoring
    case productionFirebase = "production_firebase"
}

enum MarketQualificationStatus: String, Codable, Equatable {
    case notStarted = "not_started"
    case verified
}

enum MarketQualificationEvidence: Codable, Equatable {
    case manualReview(note: String)
    case command(name: String, result: String)
}

struct MarketQualificationItem: Identifiable, Codable, Equatable {
    let id: String
    let area: MarketQualificationArea
    let title: String
    let isRequired: Bool
    var status: MarketQualificationStatus
    var evidence: MarketQualificationEvidence?

    init(
        area: MarketQualificationArea,
        title: String,
        isRequired: Bool = true,
        status: MarketQualificationStatus = .notStarted,
        evidence: MarketQualificationEvidence? = nil
    ) {
        id = area.rawValue
        self.area = area
        self.title = title
        self.isRequired = isRequired
        self.status = status
        self.evidence = evidence
    }
}

struct MarketQualificationChecklist: Codable, Equatable {
    var items: [MarketQualificationItem]

    static func defaultReleaseGate() -> MarketQualificationChecklist {
        MarketQualificationChecklist(items: [
            MarketQualificationItem(area: .localization, title: "Localization coverage"),
            MarketQualificationItem(area: .accessibility, title: "Real-device accessibility QA"),
            MarketQualificationItem(area: .performance, title: "Performance profiling"),
            MarketQualificationItem(area: .securityPrivacy, title: "Security and privacy review"),
            MarketQualificationItem(area: .moderationOperations, title: "Moderation operations"),
            MarketQualificationItem(area: .testFlightEvidence, title: "TestFlight evidence"),
            MarketQualificationItem(area: .monitoring, title: "Monitoring and diagnostics"),
            MarketQualificationItem(area: .productionFirebase, title: "Owner-approved production Firebase")
        ])
    }

    var isReadyForLaunch: Bool {
        items
            .filter(\.isRequired)
            .allSatisfy { $0.status == .verified && $0.evidence != nil }
    }

    var statusSummary: String {
        let requiredItems = items.filter(\.isRequired)
        let verifiedCount = requiredItems.filter { $0.status == .verified }.count
        return "\(verifiedCount) of \(requiredItems.count) required gates verified"
    }

    mutating func recordEvidence(
        for area: MarketQualificationArea,
        evidence: MarketQualificationEvidence
    ) {
        guard let index = items.firstIndex(where: { $0.area == area }) else {
            return
        }

        items[index].evidence = evidence
        items[index].status = .verified
    }
}
