import Foundation

enum InquiryStatus: String, Codable, CaseIterable {
    case submitted
    case acknowledged
    case viewingScheduled = "viewing_scheduled"
    case accepted
    case rejected
    case cancelled
    case expired

    func canTransition(to next: InquiryStatus) -> Bool {
        switch (self, next) {
        case (.submitted, .acknowledged),
             (.submitted, .rejected),
             (.submitted, .cancelled),
             (.submitted, .expired),
             (.acknowledged, .viewingScheduled),
             (.acknowledged, .accepted),
             (.acknowledged, .rejected),
             (.acknowledged, .cancelled),
             (.acknowledged, .expired),
             (.viewingScheduled, .accepted),
             (.viewingScheduled, .rejected),
             (.viewingScheduled, .cancelled),
             (.viewingScheduled, .expired):
            true
        default:
            false
        }
    }
}

struct Inquiry: Identifiable, Codable, Equatable {
    let schemaVersion: Int
    let id: String
    let listingId: String
    let landlordId: String
    let renterId: String
    var status: InquiryStatus
    var message: String?
    var preferredViewingDate: Date?
    var createdAt: Date?
    var updatedAt: Date?

    init(
        id: String,
        listingId: String,
        landlordId: String,
        renterId: String,
        status: InquiryStatus = .submitted,
        message: String? = nil,
        preferredViewingDate: Date? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
        schemaVersion = 1
        self.id = id
        self.listingId = listingId
        self.landlordId = landlordId
        self.renterId = renterId
        self.status = status
        self.message = message
        self.preferredViewingDate = preferredViewingDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
