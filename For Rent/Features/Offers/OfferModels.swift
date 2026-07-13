import Foundation

enum OfferParty: String, Codable, Equatable {
    case renter
    case manager
}

enum OfferStatus: String, Codable, Equatable {
    case draft
    case submitted
    case countered
    case mutuallyAccepted = "mutually_accepted"
    case rejected
    case withdrawn
    case expired
}

enum OfferTransitionError: LocalizedError, Equatable {
    case closed(status: OfferStatus)
    case noVersion
    case notExpired

    var errorDescription: String? {
        switch self {
        case let .closed(status):
            return "Offer is closed with status \(status.rawValue)."
        case .noVersion:
            return "Offer has no version to update."
        case .notExpired:
            return "Offer has not reached its expiry."
        }
    }
}

struct RentalOfferTerms: Codable, Equatable {
    let monthlyRent: Decimal
    let desiredMoveInDate: Date
    let leaseLengthMonths: Int
    let includesParking: Bool
    let includesStorage: Bool
    let includesUtilities: Bool
    let includesFurnishings: Bool
    let occupancyCount: Int
    let conditions: [String]
    let expiresAt: Date
    let note: String?
}

struct OfferVersion: Identifiable, Codable, Equatable {
    let schemaVersion: Int
    let id: String
    let offerId: String
    let versionNumber: Int
    let proposer: OfferParty
    let terms: RentalOfferTerms
    let createdAt: Date
    var renterApprovalAt: Date?
    var managerApprovalAt: Date?

    init(
        id: String,
        offerId: String,
        versionNumber: Int,
        proposer: OfferParty,
        terms: RentalOfferTerms,
        createdAt: Date
    ) {
        schemaVersion = 1
        self.id = id
        self.offerId = offerId
        self.versionNumber = versionNumber
        self.proposer = proposer
        self.terms = terms
        self.createdAt = createdAt

        switch proposer {
        case .renter:
            renterApprovalAt = createdAt
            managerApprovalAt = nil
        case .manager:
            renterApprovalAt = nil
            managerApprovalAt = createdAt
        }
    }

    var isMutuallyApproved: Bool {
        renterApprovalAt != nil && managerApprovalAt != nil
    }

    mutating func approve(party: OfferParty, at date: Date) {
        switch party {
        case .renter:
            renterApprovalAt = date
        case .manager:
            managerApprovalAt = date
        }
    }
}

struct RentalOffer: Identifiable, Codable, Equatable {
    let schemaVersion: Int
    let id: String
    let propertyId: String
    let conversationId: String
    let renterId: String
    let managerId: String
    var status: OfferStatus
    var versions: [OfferVersion]

    var latestVersion: OfferVersion {
        versions[versions.count - 1]
    }

    static func submitted(
        id: String,
        propertyId: String,
        conversationId: String,
        renterId: String,
        managerId: String,
        proposer: OfferParty,
        terms: RentalOfferTerms,
        createdAt: Date
    ) -> RentalOffer {
        RentalOffer(
            id: id,
            propertyId: propertyId,
            conversationId: conversationId,
            renterId: renterId,
            managerId: managerId,
            status: .submitted,
            versions: [
                OfferVersion(
                    id: "\(id)-v1",
                    offerId: id,
                    versionNumber: 1,
                    proposer: proposer,
                    terms: terms,
                    createdAt: createdAt
                )
            ]
        )
    }

    init(
        id: String,
        propertyId: String,
        conversationId: String,
        renterId: String,
        managerId: String,
        status: OfferStatus,
        versions: [OfferVersion]
    ) {
        schemaVersion = 1
        self.id = id
        self.propertyId = propertyId
        self.conversationId = conversationId
        self.renterId = renterId
        self.managerId = managerId
        self.status = status
        self.versions = versions
    }

    mutating func counter(
        proposer: OfferParty,
        terms: RentalOfferTerms,
        createdAt: Date
    ) throws {
        try ensureOpen()
        let versionNumber = versions.count + 1
        versions.append(OfferVersion(
            id: "\(id)-v\(versionNumber)",
            offerId: id,
            versionNumber: versionNumber,
            proposer: proposer,
            terms: terms,
            createdAt: createdAt
        ))
        status = .countered
    }

    mutating func approveLatestVersion(party: OfferParty, approvedAt: Date) throws {
        try ensureOpen()
        guard let latestIndex = versions.indices.last else {
            throw OfferTransitionError.noVersion
        }

        versions[latestIndex].approve(party: party, at: approvedAt)
        if versions[latestIndex].isMutuallyApproved {
            status = .mutuallyAccepted
        }
    }

    mutating func expire(at date: Date) throws {
        guard let latest = versions.last else {
            throw OfferTransitionError.noVersion
        }
        guard date >= latest.terms.expiresAt else {
            throw OfferTransitionError.notExpired
        }

        status = .expired
    }

    private func ensureOpen() throws {
        switch status {
        case .draft, .submitted, .countered:
            return
        case .mutuallyAccepted, .rejected, .withdrawn, .expired:
            throw OfferTransitionError.closed(status: status)
        }
    }
}
