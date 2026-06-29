import Foundation

protocol DocumentRepositoryProtocol: Sendable {
    func getDocuments() async throws -> [UserDocument]
    func importDocument(from url: URL, type: DocumentType) async throws -> UserDocument
    func deleteDocument(id: UUID) async throws
    func setPrimaryDocument(id: UUID, type: DocumentType) async throws
    func exportDocument(id: UUID) async throws -> URL
    func uploadDocument(id: UUID, progress: (@Sendable (Double) -> Void)?) async throws -> URL
}