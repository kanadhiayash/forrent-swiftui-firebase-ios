import Foundation

protocol ConversationRepository {
    func conversation(propertyId: String, renterId: String, managerId: String) async throws -> Conversation?
    func upsertConversation(_ conversation: Conversation) async throws
    func messages(conversationId: String) async throws -> [Message]
    func events(conversationId: String) async throws -> [ConversationEvent]
    func sendMessage(_ message: Message) async throws
    func appendEvent(_ event: ConversationEvent) async throws
}
