import Foundation

enum JourneyStage: String, CaseIterable, Equatable {
    case listing
    case conversation
    case viewing
    case postViewingDecision
    case offer
    case mutualApproval
    case ended

    var title: String {
        switch self {
        case .listing: "Listing"
        case .conversation: "Conversation"
        case .viewing: "Viewing"
        case .postViewingDecision: "Decision"
        case .offer: "Offer"
        case .mutualApproval: "Mutual yes"
        case .ended: "Ended"
        }
    }
}

enum JourneyStepState: Equatable {
    case complete
    case active
    case locked
    case ended
}

struct JourneyTimelineStep: Identifiable, Equatable {
    let stage: JourneyStage
    let title: String
    let detail: String
    let state: JourneyStepState

    var id: JourneyStage { stage }
}

struct JourneyTimelineSnapshot: Identifiable, Equatable {
    let requestId: String
    let propertyTitle: String
    let propertyLocation: String
    let statusTitle: String
    let currentStage: JourneyStage
    let primaryActionTitle: String
    let isEnded: Bool
    let isCompletionEligible: Bool
    let steps: [JourneyTimelineStep]

    var id: String { requestId }

    init(request: Request, property: Property?) {
        requestId = request.id
        propertyTitle = property?.title ?? "Rental inquiry"
        propertyLocation = property?.resolvedLocationName ?? "Location unavailable"
        statusTitle = request.status.title

        let resolved = Self.resolve(status: request.status)
        currentStage = resolved.stage
        primaryActionTitle = resolved.action
        isEnded = resolved.ended
        isCompletionEligible = false
        steps = Self.steps(for: request.status)
    }

    private static func resolve(status: RequestStatus) -> (stage: JourneyStage, action: String, ended: Bool) {
        switch status {
        case .submitted:
            return (.conversation, "Open conversation", false)
        case .acknowledged:
            return (.viewing, "Book a viewing", false)
        case .viewingScheduled:
            return (.viewing, "View booking details", false)
        case .accepted:
            return (.offer, "Create structured offer", false)
        case .rejected, .cancelled, .expired:
            return (.ended, "Review summary", true)
        }
    }

    private static func steps(for status: RequestStatus) -> [JourneyTimelineStep] {
        let ended = [.rejected, .cancelled, .expired].contains(status)
        return [
            JourneyTimelineStep(
                stage: .listing,
                title: "Listing selected",
                detail: "The property context stays attached to the journey.",
                state: ended ? .complete : .complete
            ),
            JourneyTimelineStep(
                stage: .conversation,
                title: "Conversation",
                detail: "Questions, manager replies, and workflow cards live together.",
                state: conversationState(for: status)
            ),
            JourneyTimelineStep(
                stage: .viewing,
                title: "Viewing",
                detail: "Book from verified manager availability, then track the appointment.",
                state: viewingState(for: status)
            ),
            JourneyTimelineStep(
                stage: .postViewingDecision,
                title: "Post-viewing decision",
                detail: "After the visit, choose yes, no, or not sure before any offer.",
                state: postViewingState(for: status)
            ),
            JourneyTimelineStep(
                stage: .offer,
                title: "Structured offer",
                detail: "Rent, move-in, lease length, conditions, and expiry are versioned.",
                state: offerState(for: status)
            ),
            JourneyTimelineStep(
                stage: .mutualApproval,
                title: "Mutual approval",
                detail: "Completion requires both parties approving the same offer version.",
                state: ended ? .ended : .locked
            )
        ]
    }

    private static func conversationState(for status: RequestStatus) -> JourneyStepState {
        switch status {
        case .submitted, .acknowledged: .active
        case .viewingScheduled, .accepted: .complete
        case .rejected, .cancelled, .expired: .ended
        }
    }

    private static func viewingState(for status: RequestStatus) -> JourneyStepState {
        switch status {
        case .submitted: .locked
        case .acknowledged, .viewingScheduled: .active
        case .accepted: .complete
        case .rejected, .cancelled, .expired: .ended
        }
    }

    private static func postViewingState(for status: RequestStatus) -> JourneyStepState {
        switch status {
        case .accepted: .complete
        case .viewingScheduled: .locked
        case .submitted, .acknowledged: .locked
        case .rejected, .cancelled, .expired: .ended
        }
    }

    private static func offerState(for status: RequestStatus) -> JourneyStepState {
        switch status {
        case .accepted: .active
        case .submitted, .acknowledged, .viewingScheduled: .locked
        case .rejected, .cancelled, .expired: .ended
        }
    }
}
