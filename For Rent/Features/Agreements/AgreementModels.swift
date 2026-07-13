import Foundation

enum AgreementJurisdiction: String, Codable, Equatable {
    case ontario
    case legalReviewRequired = "legal_review_required"
}

enum AgreementDraftStatus: String, Codable, Equatable {
    case preparation
    case correctionRequested = "correction_requested"
    case readyForExport = "ready_for_export"
    case exported
}

enum AgreementDraftError: LocalizedError, Equatable {
    case offerNotMutuallyAccepted
    case unsupportedJurisdiction
    case missingApprovedVersion
    case emptyCorrectionNote

    var errorDescription: String? {
        switch self {
        case .offerNotMutuallyAccepted:
            return "Agreement preparation requires mutual approval on the latest offer version."
        case .unsupportedJurisdiction:
            return "This jurisdiction requires legal review before template generation."
        case .missingApprovedVersion:
            return "The offer has no mutually approved version to map."
        case .emptyCorrectionNote:
            return "Correction requests need a note."
        }
    }
}

struct OntarioStandardLeaseFieldMap: Codable, Equatable {
    let sourceOfferVersionId: String
    let monthlyRent: Decimal
    let desiredMoveInDate: Date
    let leaseLengthMonths: Int
    let includesParking: Bool
    let includesStorage: Bool
    let includesUtilities: Bool
    let includesFurnishings: Bool
    let occupancyCount: Int
    let conditions: [String]
    let note: String?

    init(version: OfferVersion) {
        sourceOfferVersionId = version.id
        monthlyRent = version.terms.monthlyRent
        desiredMoveInDate = version.terms.desiredMoveInDate
        leaseLengthMonths = version.terms.leaseLengthMonths
        includesParking = version.terms.includesParking
        includesStorage = version.terms.includesStorage
        includesUtilities = version.terms.includesUtilities
        includesFurnishings = version.terms.includesFurnishings
        occupancyCount = version.terms.occupancyCount
        conditions = version.terms.conditions
        note = version.terms.note
    }
}

struct AgreementRevision: Identifiable, Codable, Equatable {
    let schemaVersion: Int
    let id: String
    let requestedBy: OfferParty
    let note: String
    let createdAt: Date

    init(id: String, requestedBy: OfferParty, note: String, createdAt: Date) {
        schemaVersion = 1
        self.id = id
        self.requestedBy = requestedBy
        self.note = note
        self.createdAt = createdAt
    }
}

struct AgreementDraft: Identifiable, Codable, Equatable {
    let schemaVersion: Int
    let id: String
    let offerId: String
    let conversationId: String
    let propertyId: String
    let approvedOfferVersionId: String
    let jurisdiction: AgreementJurisdiction
    var status: AgreementDraftStatus
    let fieldMap: OntarioStandardLeaseFieldMap
    let legalNotice: String
    let createdAt: Date
    var revisions: [AgreementRevision]

    static func prepare(
        id: String,
        offer: RentalOffer,
        jurisdiction: AgreementJurisdiction,
        createdAt: Date
    ) throws -> AgreementDraft {
        guard jurisdiction == .ontario else {
            throw AgreementDraftError.unsupportedJurisdiction
        }
        guard offer.status == .mutuallyAccepted else {
            throw AgreementDraftError.offerNotMutuallyAccepted
        }
        guard let latestVersion = offer.versions.last, latestVersion.isMutuallyApproved else {
            throw AgreementDraftError.missingApprovedVersion
        }

        return AgreementDraft(
            id: id,
            offerId: offer.id,
            conversationId: offer.conversationId,
            propertyId: offer.propertyId,
            approvedOfferVersionId: latestVersion.id,
            jurisdiction: jurisdiction,
            status: .preparation,
            fieldMap: OntarioStandardLeaseFieldMap(version: latestVersion),
            legalNotice: "Ontario standard lease preparation only maps mutually approved terms and does not add clauses or replace legal review.",
            createdAt: createdAt,
            revisions: []
        )
    }

    init(
        id: String,
        offerId: String,
        conversationId: String,
        propertyId: String,
        approvedOfferVersionId: String,
        jurisdiction: AgreementJurisdiction,
        status: AgreementDraftStatus,
        fieldMap: OntarioStandardLeaseFieldMap,
        legalNotice: String,
        createdAt: Date,
        revisions: [AgreementRevision]
    ) {
        schemaVersion = 1
        self.id = id
        self.offerId = offerId
        self.conversationId = conversationId
        self.propertyId = propertyId
        self.approvedOfferVersionId = approvedOfferVersionId
        self.jurisdiction = jurisdiction
        self.status = status
        self.fieldMap = fieldMap
        self.legalNotice = legalNotice
        self.createdAt = createdAt
        self.revisions = revisions
    }

    mutating func requestCorrection(
        id: String,
        requestedBy: OfferParty,
        note: String,
        createdAt: Date
    ) throws {
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedNote.isEmpty else {
            throw AgreementDraftError.emptyCorrectionNote
        }

        revisions.append(AgreementRevision(
            id: id,
            requestedBy: requestedBy,
            note: trimmedNote,
            createdAt: createdAt
        ))
        status = .correctionRequested
    }
}
