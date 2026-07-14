import Foundation

protocol AgreementRepository {
    func agreement(id: String) async throws -> AgreementDraft?
    func agreements(offerId: String) async throws -> [AgreementDraft]
    func saveAgreement(_ agreement: AgreementDraft) async throws
}
