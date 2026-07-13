import Foundation

protocol OfferRepository {
    func offer(id: String) async throws -> RentalOffer?
    func offers(conversationId: String) async throws -> [RentalOffer]
    func saveOffer(_ offer: RentalOffer) async throws
}
