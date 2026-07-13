import Foundation

struct PostViewingDecisionOption: Identifiable, Equatable {
    let choice: PostViewingChoice

    var id: PostViewingChoice { choice }

    var title: String {
        switch choice {
        case .yes:
            return "Yes, move ahead"
        case .notSure:
            return "Not sure yet"
        case .no:
            return "No, end journey"
        }
    }

    var detail: String {
        switch choice {
        case .yes:
            return "Open a structured offer with terms, conditions, and expiry."
        case .notSure:
            return "Keep the journey open for one reminder window without signaling yes."
        case .no:
            return "Archive this listing journey while keeping the conversation read-only."
        }
    }

    var systemImage: String {
        switch choice {
        case .yes:
            return "checkmark.circle.fill"
        case .notSure:
            return "clock.badge.questionmark"
        case .no:
            return "archivebox.fill"
        }
    }

    var continuationTitle: String {
        switch choice {
        case .yes:
            return "Start structured offer"
        case .notSure:
            return "Set one reminder"
        case .no:
            return "End this listing journey"
        }
    }
}

struct PostViewingDecisionSnapshot: Equatable {
    let viewingId: String
    let propertyTitle: String
    let propertyLocation: String
    let promptTitle: String
    let promptDetail: String
    let isPromptReady: Bool
    let options: [PostViewingDecisionOption]

    init(viewing: Viewing, property: Property?, now: Date, graceMinutes: Int) {
        viewingId = viewing.id
        propertyTitle = property?.title ?? "Rental inquiry"
        propertyLocation = property?.resolvedLocationName ?? "Location unavailable"

        if PostViewingPromptEligibility.canPrompt(viewing: viewing, at: now, graceMinutes: graceMinutes) {
            promptTitle = "Still interested in this home?"
            promptDetail = "Your answer decides whether this listing ends, waits, or moves into a structured offer."
            isPromptReady = true
            options = [.yes, .notSure, .no].map(PostViewingDecisionOption.init(choice:))
        } else {
            promptTitle = "Check-in unavailable"
            promptDetail = Self.unavailableDetail(for: viewing.status)
            isPromptReady = false
            options = []
        }
    }

    private static func unavailableDetail(for status: ViewingStatus) -> String {
        switch status {
        case .cancelled:
            return "Cancelled viewings cannot advance to an offer."
        case .missed:
            return "Missed viewings must be resolved before a renter can continue."
        case .completed:
            return "The decision prompt opens after the viewing grace period."
        case .available, .reserved, .confirmed, .rescheduled:
            return "Complete the scheduled viewing before deciding whether to continue."
        }
    }
}
