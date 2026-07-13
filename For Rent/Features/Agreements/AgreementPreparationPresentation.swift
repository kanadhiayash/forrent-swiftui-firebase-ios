import Foundation

struct AgreementTermSummary: Equatable, Identifiable {
    let id: String
    let title: String
    let value: String

    init(title: String, value: String) {
        id = title
        self.title = title
        self.value = value
    }
}

struct AgreementPreparationSnapshot: Equatable {
    let statusTitle: String
    let approvedVersionTitle: String
    let monthlyRentTitle: String
    let legalNotice: String
    let confirmedTerms: [AgreementTermSummary]
    let requiredDocuments: [String]
    let primaryActionTitle: String

    init(
        offer: RentalOffer,
        jurisdiction: AgreementJurisdiction,
        now: Date
    ) throws {
        let draft = try AgreementDraft.prepare(
            id: "agreement__\(offer.id)",
            offer: offer,
            jurisdiction: jurisdiction,
            createdAt: now
        )

        statusTitle = "Agreement preparation"
        approvedVersionTitle = "Approved offer version \(offer.latestVersion.versionNumber)"
        monthlyRentTitle = Self.moneyTitle(for: draft.fieldMap.monthlyRent)
        legalNotice = draft.legalNotice
        confirmedTerms = Self.confirmedTerms(for: draft.fieldMap)
        requiredDocuments = [
            "Mutually approved offer summary",
            "Identity and contact review",
            "Ontario standard lease field review",
            "Corrections request log"
        ]
        primaryActionTitle = "Prepare draft package"
    }

    static func blocked(offer: RentalOffer) -> AgreementPreparationSnapshot {
        AgreementPreparationSnapshot(
            statusTitle: "Waiting for mutual approval",
            approvedVersionTitle: "Latest offer version \(offer.latestVersion.versionNumber)",
            monthlyRentTitle: Self.moneyTitle(for: offer.latestVersion.terms.monthlyRent),
            legalNotice: "Agreement preparation starts only after the same offer version has both approval timestamps.",
            confirmedTerms: Self.confirmedTerms(for: offer.latestVersion.terms),
            requiredDocuments: [
                "Mutually approved offer summary",
                "Identity and contact review",
                "Legal template review"
            ],
            primaryActionTitle: "Return to offer"
        )
    }

    private init(
        statusTitle: String,
        approvedVersionTitle: String,
        monthlyRentTitle: String,
        legalNotice: String,
        confirmedTerms: [AgreementTermSummary],
        requiredDocuments: [String],
        primaryActionTitle: String
    ) {
        self.statusTitle = statusTitle
        self.approvedVersionTitle = approvedVersionTitle
        self.monthlyRentTitle = monthlyRentTitle
        self.legalNotice = legalNotice
        self.confirmedTerms = confirmedTerms
        self.requiredDocuments = requiredDocuments
        self.primaryActionTitle = primaryActionTitle
    }

    private static func confirmedTerms(for fieldMap: OntarioStandardLeaseFieldMap) -> [AgreementTermSummary] {
        [
            AgreementTermSummary(title: "Move-in", value: dateTitle(for: fieldMap.desiredMoveInDate)),
            AgreementTermSummary(title: "Lease", value: "\(fieldMap.leaseLengthMonths) months"),
            AgreementTermSummary(title: "Occupancy", value: "\(fieldMap.occupancyCount)"),
            AgreementTermSummary(title: "Included", value: includedTitle(
                parking: fieldMap.includesParking,
                storage: fieldMap.includesStorage,
                utilities: fieldMap.includesUtilities,
                furnishings: fieldMap.includesFurnishings
            )),
            AgreementTermSummary(title: "Conditions", value: fieldMap.conditions.isEmpty ? "None" : fieldMap.conditions.joined(separator: ", "))
        ]
    }

    private static func confirmedTerms(for terms: RentalOfferTerms) -> [AgreementTermSummary] {
        [
            AgreementTermSummary(title: "Move-in", value: dateTitle(for: terms.desiredMoveInDate)),
            AgreementTermSummary(title: "Lease", value: "\(terms.leaseLengthMonths) months"),
            AgreementTermSummary(title: "Occupancy", value: "\(terms.occupancyCount)"),
            AgreementTermSummary(title: "Included", value: includedTitle(
                parking: terms.includesParking,
                storage: terms.includesStorage,
                utilities: terms.includesUtilities,
                furnishings: terms.includesFurnishings
            )),
            AgreementTermSummary(title: "Conditions", value: terms.conditions.isEmpty ? "None" : terms.conditions.joined(separator: ", "))
        ]
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

    private static func dateTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_CA")
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    private static func includedTitle(
        parking: Bool,
        storage: Bool,
        utilities: Bool,
        furnishings: Bool
    ) -> String {
        var included: [String] = []
        if parking { included.append("Parking") }
        if storage { included.append("Storage") }
        if utilities { included.append("Utilities") }
        if furnishings { included.append("Furnishings") }
        return included.isEmpty ? "None specified" : included.joined(separator: ", ")
    }
}
