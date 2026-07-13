import Foundation

protocol AvailabilityRepository {
    func profile(propertyId: String, managerId: String) async throws -> AvailabilityProfile?
    func saveProfile(_ profile: AvailabilityProfile) async throws
    func slots(propertyId: String, from startDate: Date, through endDate: Date) async throws -> [ViewingSlot]
}

protocol ViewingRepository {
    func reserve(slot: ViewingSlot, renterId: String, conversationId: String) async throws -> Viewing
    func viewing(id: String) async throws -> Viewing?
    func saveViewing(_ viewing: Viewing) async throws
}
