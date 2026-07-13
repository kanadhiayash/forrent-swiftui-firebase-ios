import Foundation

struct StructuredOfferDraft: Equatable {
    enum ValidationError: LocalizedError, Equatable {
        case invalidMonthlyRent
        case invalidLeaseLength
        case invalidOccupancy

        var errorDescription: String? {
            switch self {
            case .invalidMonthlyRent:
                return "Enter a valid monthly rent."
            case .invalidLeaseLength:
                return "Lease length must be at least one month."
            case .invalidOccupancy:
                return "Occupancy must be at least one person."
            }
        }
    }

    var monthlyRentText: String
    var moveInDate: Date
    var leaseLengthMonths: Int
    var includesParking: Bool
    var includesStorage: Bool
    var includesUtilities: Bool
    var includesFurnishings: Bool
    var occupancyCount: Int
    var conditionsText: String
    var note: String
    var expiryHours: Int

    init(monthlyRentText: String = "") {
        self.monthlyRentText = monthlyRentText
        moveInDate = Date().addingTimeInterval(14 * 24 * 60 * 60)
        leaseLengthMonths = 12
        includesParking = false
        includesStorage = false
        includesUtilities = false
        includesFurnishings = false
        occupancyCount = 1
        conditionsText = ""
        note = ""
        expiryHours = 48
    }

    func makeTerms(now: Date) throws -> RentalOfferTerms {
        guard let monthlyRent = Decimal(string: monthlyRentText.trimmingCharacters(in: .whitespacesAndNewlines)),
              monthlyRent > 0 else {
            throw ValidationError.invalidMonthlyRent
        }

        guard leaseLengthMonths > 0 else {
            throw ValidationError.invalidLeaseLength
        }

        guard occupancyCount > 0 else {
            throw ValidationError.invalidOccupancy
        }

        return RentalOfferTerms(
            monthlyRent: monthlyRent,
            desiredMoveInDate: moveInDate,
            leaseLengthMonths: leaseLengthMonths,
            includesParking: includesParking,
            includesStorage: includesStorage,
            includesUtilities: includesUtilities,
            includesFurnishings: includesFurnishings,
            occupancyCount: occupancyCount,
            conditions: parsedConditions,
            expiresAt: now.addingTimeInterval(TimeInterval(max(1, expiryHours) * 60 * 60)),
            note: note.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        )
    }

    private var parsedConditions: [String] {
        conditionsText
            .components(separatedBy: CharacterSet(charactersIn: ",\n"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}

struct OfferReviewSnapshot: Equatable {
    let offerId: String
    let statusTitle: String
    let versionTitle: String
    let monthlyRentTitle: String
    let leaseTitle: String
    let moveInTitle: String
    let includedTerms: [String]
    let conditions: [String]
    let approvalSummary: String

    init(offer: RentalOffer) {
        let latest = offer.latestVersion
        offerId = offer.id
        statusTitle = offer.status.title
        versionTitle = "Version \(latest.versionNumber)"
        monthlyRentTitle = Self.moneyTitle(for: latest.terms.monthlyRent)
        leaseTitle = "\(latest.terms.leaseLengthMonths)-month lease"
        moveInTitle = latest.terms.desiredMoveInDate.formatted(date: .abbreviated, time: .omitted)
        includedTerms = Self.includedTerms(for: latest.terms)
        conditions = latest.terms.conditions
        approvalSummary = Self.approvalSummary(for: latest)
    }

    private static func moneyTitle(for decimal: Decimal) -> String {
        let number = NSDecimalNumber(decimal: decimal)
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_CA")
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        let formatted = formatter.string(from: number) ?? number.stringValue
        return "$\(formatted) CAD"
    }

    private static func includedTerms(for terms: RentalOfferTerms) -> [String] {
        var termsList: [String] = []
        if terms.includesParking { termsList.append("Parking") }
        if terms.includesStorage { termsList.append("Storage") }
        if terms.includesUtilities { termsList.append("Utilities") }
        if terms.includesFurnishings { termsList.append("Furnishings") }
        return termsList
    }

    private static func approvalSummary(for version: OfferVersion) -> String {
        switch (version.renterApprovalAt, version.managerApprovalAt) {
        case (.some, .some):
            return "Both parties approved this version."
        case (.some, nil):
            return "Renter approved. Waiting for manager approval."
        case (nil, .some):
            return "Manager approved. Waiting for renter approval."
        case (nil, nil):
            return "Waiting for approvals."
        }
    }
}

private extension OfferStatus {
    var title: String {
        switch self {
        case .draft:
            return "Draft"
        case .submitted:
            return "Submitted"
        case .countered:
            return "Countered"
        case .mutuallyAccepted:
            return "Mutually accepted"
        case .rejected:
            return "Rejected"
        case .withdrawn:
            return "Withdrawn"
        case .expired:
            return "Expired"
        }
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
