import Foundation

enum ConversationStatus: String, Codable, Equatable {
    case active
    case archived
    case blocked
}

enum ConversationParticipantRole: String, Codable, Equatable {
    case renter
    case manager
    case system
}

enum ConversationValidationError: LocalizedError, Equatable {
    case emptyMessage

    var errorDescription: String? {
        switch self {
        case .emptyMessage:
            return "Message cannot be empty."
        }
    }
}

struct Conversation: Identifiable, Codable, Equatable {
    let schemaVersion: Int
    let id: String
    let propertyId: String
    let renterId: String
    let managerId: String
    var status: ConversationStatus
    var createdAt: Date
    var updatedAt: Date

    init(
        id: String? = nil,
        propertyId: String,
        renterId: String,
        managerId: String,
        status: ConversationStatus = .active,
        createdAt: Date,
        updatedAt: Date
    ) {
        schemaVersion = 1
        self.propertyId = propertyId
        self.renterId = renterId
        self.managerId = managerId
        self.id = id ?? Self.propertyScopedId(
            propertyId: propertyId,
            renterId: renterId,
            managerId: managerId
        )
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    static func propertyScopedId(propertyId: String, renterId: String, managerId: String) -> String {
        [
            propertyId.firestorePathSafe,
            renterId.firestorePathSafe,
            managerId.firestorePathSafe
        ].joined(separator: "__")
    }
}

struct Message: Identifiable, Codable, Equatable {
    let schemaVersion: Int
    let id: String
    let conversationId: String
    let senderId: String
    let senderRole: ConversationParticipantRole
    let body: String
    let createdAt: Date

    init(
        id: String,
        conversationId: String,
        senderId: String,
        senderRole: ConversationParticipantRole,
        body: String,
        createdAt: Date
    ) throws {
        let cleanedBody = body.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedBody.isEmpty else {
            throw ConversationValidationError.emptyMessage
        }

        schemaVersion = 1
        self.id = id
        self.conversationId = conversationId
        self.senderId = senderId
        self.senderRole = senderRole
        self.body = cleanedBody
        self.createdAt = createdAt
    }
}

enum ConversationEventKind: String, Codable, Equatable {
    case viewingReserved = "viewing_reserved"
    case viewingRescheduled = "viewing_rescheduled"
    case viewingCancelled = "viewing_cancelled"
    case offerSubmitted = "offer_submitted"
    case offerCountered = "offer_countered"
    case offerApproved = "offer_approved"
    case offerRejected = "offer_rejected"
    case mutualDecisionCreated = "mutual_decision_created"
}

struct ConversationWorkflowReference: Codable, Equatable {
    let collection: String
    let id: String
}

struct ConversationEvent: Identifiable, Codable, Equatable {
    let schemaVersion: Int
    let id: String
    let conversationId: String
    let kind: ConversationEventKind
    let actorId: String
    let reference: ConversationWorkflowReference
    let createdAt: Date

    var completesJourney: Bool {
        kind == .mutualDecisionCreated
    }

    static func viewingReserved(
        id: String,
        conversationId: String,
        actorId: String,
        viewingId: String,
        createdAt: Date
    ) -> ConversationEvent {
        ConversationEvent(
            id: id,
            conversationId: conversationId,
            kind: .viewingReserved,
            actorId: actorId,
            reference: ConversationWorkflowReference(collection: "viewings", id: viewingId),
            createdAt: createdAt
        )
    }

    static func mutualDecisionCreated(
        id: String,
        conversationId: String,
        actorId: String,
        decisionId: String,
        createdAt: Date
    ) -> ConversationEvent {
        ConversationEvent(
            id: id,
            conversationId: conversationId,
            kind: .mutualDecisionCreated,
            actorId: actorId,
            reference: ConversationWorkflowReference(collection: "mutualDecisions", id: decisionId),
            createdAt: createdAt
        )
    }

    private init(
        id: String,
        conversationId: String,
        kind: ConversationEventKind,
        actorId: String,
        reference: ConversationWorkflowReference,
        createdAt: Date
    ) {
        schemaVersion = 1
        self.id = id
        self.conversationId = conversationId
        self.kind = kind
        self.actorId = actorId
        self.reference = reference
        self.createdAt = createdAt
    }
}

private extension String {
    var firestorePathSafe: String {
        replacingOccurrences(of: "/", with: "_")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
