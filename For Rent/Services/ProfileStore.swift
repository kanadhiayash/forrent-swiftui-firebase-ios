import Foundation

protocol ProfileStore {
    func updateProfile(
        userId: String,
        firstName: String,
        lastName: String,
        phone: String
    ) async throws
}

struct FirestoreProfileStore: ProfileStore {
    func updateProfile(
        userId: String,
        firstName: String,
        lastName: String,
        phone: String
    ) async throws {
        try await FirestoreService.shared.updateProfile(
            userId: userId,
            firstName: firstName,
            lastName: lastName,
            phone: phone
        )
    }
}
