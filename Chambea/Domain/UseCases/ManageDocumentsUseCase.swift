import Foundation

struct ManageDocumentsUseCase: Sendable {
    let repository: DocumentRepositoryProtocol

    func importFile(from url: URL, type: DocumentType) async throws -> UserDocument {
        try await repository.importDocument(from: url, type: type)
    }

    func export(id: UUID) async throws -> URL {
        try await repository.exportDocument(id: id)
    }

    func delete(id: UUID) async throws {
        try await repository.deleteDocument(id: id)
    }
}