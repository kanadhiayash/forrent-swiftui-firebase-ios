import Foundation

protocol PostViewingDecisionRepository {
    func decision(viewingId: String, renterId: String) async throws -> PostViewingDecision?
    func saveDecision(_ decision: PostViewingDecision) async throws
}
