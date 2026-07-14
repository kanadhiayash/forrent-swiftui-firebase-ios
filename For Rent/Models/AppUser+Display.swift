import Foundation

extension AppUser {
    var displayName: String {
        let parts = [firstName, lastName]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        return parts.isEmpty ? "Account" : parts.joined(separator: " ")
    }

    var initials: String {
        let characters = [firstName, lastName]
            .compactMap { value in
                value
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .first
            }

        let result = String(characters.prefix(2)).uppercased()
        return result.isEmpty ? "FR" : result
    }

    var roleDisplayName: String {
        switch role {
        case .guest:
            "Guest"
        case .tenant:
            "Renter"
        case .landlord:
            "Landlord"
        }
    }

    var formattedPhoneForDisplay: String? {
        let value = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }
}
