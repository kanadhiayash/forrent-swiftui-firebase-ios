import Foundation
import Observation

struct ProfileDraft: Equatable {
    var firstName: String
    var lastName: String
    var phone: String

    init(user: AppUser) {
        firstName = user.firstName
        lastName = user.lastName
        phone = user.phone
    }

    var normalized: ProfileDraft {
        ProfileDraft(
            firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
            phone: Self.normalizedPhone(phone)
        )
    }

    private init(firstName: String, lastName: String, phone: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.phone = phone
    }

    private static func normalizedPhone(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\u{2013}", with: "-")
            .replacingOccurrences(of: "\u{2014}", with: "-")
    }
}

struct ProfileFieldErrors: Equatable {
    var firstName: String?
    var lastName: String?
    var phone: String?

    var hasErrors: Bool {
        firstName != nil || lastName != nil || phone != nil
    }
}

enum ProfileSubmissionState: Equatable {
    case idle
    case saving
    case failed(message: String)
}

@MainActor
@Observable
final class ProfileEditor {
    private(set) var original: ProfileDraft
    var draft: ProfileDraft
    private(set) var errors = ProfileFieldErrors()
    private(set) var submissionState: ProfileSubmissionState = .idle

    init(user: AppUser) {
        let draft = ProfileDraft(user: user)
        original = draft.normalized
        self.draft = draft
    }

    var hasChanges: Bool {
        draft.normalized != original
    }

    var isSaving: Bool {
        submissionState == .saving
    }

    var canSave: Bool {
        hasChanges && !validationErrors(for: draft.normalized).hasErrors && !isSaving
    }

    @discardableResult
    func validate() -> Bool {
        errors = validationErrors(for: draft.normalized)
        return !errors.hasErrors
    }

    func beginSaving() {
        submissionState = .saving
    }

    func finishSaving(user: AppUser) {
        let saved = ProfileDraft(user: user).normalized
        original = saved
        draft = saved
        errors = ProfileFieldErrors()
        submissionState = .idle
    }

    func fail(_ error: Error) {
        submissionState = .failed(message: error.localizedDescription)
    }

    func clearSubmissionError() {
        if case .failed = submissionState {
            submissionState = .idle
        }
    }

    private func validationErrors(for draft: ProfileDraft) -> ProfileFieldErrors {
        var errors = ProfileFieldErrors()

        if draft.firstName.isEmpty {
            errors.firstName = "Enter a first name."
        }

        if draft.lastName.isEmpty {
            errors.lastName = "Enter a last name."
        }

        if !draft.phone.isEmpty {
            let allowed = CharacterSet(charactersIn: "+0123456789()-. ")

            if draft.phone.unicodeScalars.contains(where: { !allowed.contains($0) }) {
                errors.phone = "Use digits and common phone punctuation only."
            } else {
                let digitCount = draft.phone.filter(\.isNumber).count
                if !(7...15).contains(digitCount) {
                    errors.phone = "Enter a phone number with 7 to 15 digits."
                }
            }
        }

        return errors
    }
}
