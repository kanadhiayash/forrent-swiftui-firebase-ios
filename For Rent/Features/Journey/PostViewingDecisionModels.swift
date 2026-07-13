import Foundation

enum PostViewingChoice: String, Codable, Equatable {
    case yes
    case no
    case notSure = "not_sure"
}

enum PostViewingContinuation: String, Codable, Equatable {
    case openOfferComposer = "open_offer_composer"
    case archiveReadOnly = "archive_read_only"
    case oneReminderWindow = "one_reminder_window"
}

enum PostViewingPromptEligibility {
    static func canPrompt(viewing: Viewing, at date: Date, graceMinutes: Int) -> Bool {
        guard viewing.status == .completed else { return false }
        let graceInterval = TimeInterval(max(0, graceMinutes) * 60)
        return date >= viewing.endAt.addingTimeInterval(graceInterval)
    }
}

struct PostViewingDecision: Identifiable, Codable, Equatable {
    let schemaVersion: Int
    let id: String
    let viewingId: String
    let conversationId: String
    let propertyId: String
    let renterId: String
    let choice: PostViewingChoice
    let feedback: String?
    let createdAt: Date

    init(
        id: String,
        viewingId: String,
        conversationId: String,
        propertyId: String,
        renterId: String,
        choice: PostViewingChoice,
        feedback: String?,
        createdAt: Date
    ) {
        schemaVersion = 1
        self.id = id
        self.viewingId = viewingId
        self.conversationId = conversationId
        self.propertyId = propertyId
        self.renterId = renterId
        self.choice = choice
        self.feedback = feedback?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        self.createdAt = createdAt
    }

    var continuation: PostViewingContinuation {
        switch choice {
        case .yes:
            return .openOfferComposer
        case .no:
            return .archiveReadOnly
        case .notSure:
            return .oneReminderWindow
        }
    }

    var notifiesManagerAsPositiveSignal: Bool {
        choice == .yes
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
