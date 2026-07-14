import Foundation

enum ConversationWorkflowCardKind: String, Equatable {
    case inquiry
    case viewing
    case offer
    case ended
}

struct ConversationWorkflowCard: Identifiable, Equatable {
    let kind: ConversationWorkflowCardKind
    let title: String
    let detail: String
    let systemImage: String

    var id: ConversationWorkflowCardKind { kind }
}

struct ConversationInboxItem: Identifiable, Equatable {
    let id: String
    let requestId: String
    let propertyId: String
    let propertyTitle: String
    let propertyLocation: String
    let participantTitle: String
    let latestPreview: String
    let statusTitle: String
    let nextActionTitle: String
    let isReadOnly: Bool
    let workflowCards: [ConversationWorkflowCard]

    init(request: Request, property: Property?, viewerRole: UserRole) {
        id = Conversation.propertyScopedId(
            propertyId: request.propertyId,
            renterId: request.tenantId,
            managerId: request.landlordId
        )
        requestId = request.id
        propertyId = request.propertyId
        propertyTitle = property?.title ?? "Rental inquiry"
        propertyLocation = property?.resolvedLocationName ?? "Location unavailable"
        participantTitle = viewerRole == .landlord ? request.tenantName : "Property manager"
        statusTitle = request.status.title
        latestPreview = Self.preview(for: request)
        nextActionTitle = Self.nextAction(for: request.status, viewerRole: viewerRole)
        isReadOnly = [.rejected, .cancelled, .expired].contains(request.status)
        workflowCards = Self.workflowCards(for: request.status)
    }

    private static func preview(for request: Request) -> String {
        if let message = request.message?.trimmingCharacters(in: .whitespacesAndNewlines),
           !message.isEmpty {
            return message
        }

        switch request.status {
        case .submitted:
            return "Inquiry sent. Keep the first question and listing context together."
        case .acknowledged:
            return "Manager acknowledged the inquiry. Viewing availability is next."
        case .viewingScheduled:
            return "Viewing scheduled. Track details from this conversation."
        case .accepted:
            return "Viewing moved forward. Create a structured offer before completion."
        case .rejected:
            return "Manager ended this listing journey."
        case .cancelled:
            return "Renter cancelled this listing journey."
        case .expired:
            return "This listing journey expired."
        }
    }

    private static func nextAction(for status: RequestStatus, viewerRole: UserRole) -> String {
        switch (status, viewerRole) {
        case (.submitted, .landlord):
            return "Acknowledge inquiry"
        case (.submitted, _):
            return "Continue conversation"
        case (.acknowledged, .tenant):
            return "Book viewing"
        case (.acknowledged, _):
            return "Share availability"
        case (.viewingScheduled, _):
            return "Review viewing"
        case (.accepted, .tenant):
            return "Create offer"
        case (.accepted, _):
            return "Await structured offer"
        case (.rejected, _), (.cancelled, _), (.expired, _):
            return "Review history"
        }
    }

    private static func workflowCards(for status: RequestStatus) -> [ConversationWorkflowCard] {
        switch status {
        case .submitted:
            return [
                ConversationWorkflowCard(
                    kind: .inquiry,
                    title: "Inquiry started",
                    detail: "Messages stay tied to this listing before viewing or offer work begins.",
                    systemImage: "bubble.left.and.bubble.right.fill"
                )
            ]
        case .acknowledged:
            return [
                ConversationWorkflowCard(
                    kind: .viewing,
                    title: "Viewing is next",
                    detail: "Use verified availability before moving to post-viewing decisions.",
                    systemImage: "calendar.badge.clock"
                )
            ]
        case .viewingScheduled:
            return [
                ConversationWorkflowCard(
                    kind: .viewing,
                    title: "Viewing scheduled",
                    detail: "After the viewing window passes, the renter can continue, pause, or end.",
                    systemImage: "calendar.circle.fill"
                )
            ]
        case .accepted:
            return [
                ConversationWorkflowCard(
                    kind: .offer,
                    title: "Structured offer required",
                    detail: "Completion cannot happen from chat text. Both parties must approve one offer version.",
                    systemImage: "doc.text.fill"
                )
            ]
        case .rejected, .cancelled, .expired:
            return [
                ConversationWorkflowCard(
                    kind: .ended,
                    title: "Journey ended",
                    detail: "The chat remains available as read-only history for this listing.",
                    systemImage: "archivebox.fill"
                )
            ]
        }
    }
}

struct ConversationThreadSnapshot: Identifiable, Equatable {
    let inboxItem: ConversationInboxItem
    let systemMessages: [String]
    let suggestedQuestions: [String]

    var id: String { inboxItem.id }
    var canSendMessage: Bool { !inboxItem.isReadOnly }

    init(request: Request, property: Property?, viewerRole: UserRole) {
        inboxItem = ConversationInboxItem(request: request, property: property, viewerRole: viewerRole)
        systemMessages = Self.systemMessages(for: request)
        suggestedQuestions = Self.suggestedQuestions(for: request.status, viewerRole: viewerRole)
    }

    private static func systemMessages(for request: Request) -> [String] {
        var messages = ["Conversation opened for this listing."]

        if let message = request.message?.trimmingCharacters(in: .whitespacesAndNewlines),
           !message.isEmpty {
            messages.append(message)
        }

        messages.append("Current stage: \(request.status.title).")
        return messages
    }

    private static func suggestedQuestions(for status: RequestStatus, viewerRole: UserRole) -> [String] {
        switch (status, viewerRole) {
        case (.submitted, .tenant):
            return ["Is the listing still available?", "What utilities are included?"]
        case (.submitted, .landlord):
            return ["Thanks for your interest. What move-in date are you targeting?", "Would you like to book a viewing?"]
        case (.acknowledged, .tenant):
            return ["Which viewing times are available?", "Can I confirm the total monthly cost?"]
        case (.viewingScheduled, _):
            return ["Can you confirm access instructions?", "Is parking available during the viewing?"]
        case (.accepted, .tenant):
            return ["I want to submit an offer.", "Can we review lease terms?"]
        case (.accepted, .landlord):
            return ["Please submit a structured offer when ready.", "I can review parking, utilities, and move-in timing."]
        case (.rejected, _), (.cancelled, _), (.expired, _), (.acknowledged, .landlord), (_, .guest):
            return []
        }
    }
}
