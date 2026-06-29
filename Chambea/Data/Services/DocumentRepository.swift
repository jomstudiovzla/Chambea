import Foundation
import SwiftData
import UniformTypeIdentifiers

@MainActor
final class DocumentRepository: DocumentRepositoryProtocol {
    private let modelContext: ModelContext
    private let fileProtection: FileProtectionServiceProtocol

    init(modelContext: ModelContext, fileProtection: FileProtectionServiceProtocol) {
        self.modelContext = modelContext
        self.fileProtection = fileProtection
    }

    func getDocuments() async throws -> [UserDocument] {
        let descriptor = FetchDescriptor<PersistedDocument>()
        return try modelContext.fetch(descriptor).map(mapToDomain)
    }

    func importDocument(from url: URL, type: DocumentType) async throws -> UserDocument {
        let secureDir = try fileProtection.secureDirectory()
        let destination = secureDir.appendingPathComponent("\(UUID().uuidString)-\(url.lastPathComponent)")
        let accessed = url.startAccessingSecurityScopedResource()
        defer { if accessed { url.stopAccessingSecurityScopedResource() } }
        try FileManager.default.copyItem(at: url, to: destination)
        try fileProtection.protectFile(at: destination)

        let attributes = try FileManager.default.attributesOfItem(atPath: destination.path)
        let size = (attributes[.size] as? Int64) ?? 0
        let mime = UTType(filenameExtension: url.pathExtension)?.preferredMIMEType ?? "application/octet-stream"

        let persisted = PersistedDocument()
        persisted.id = UUID()
        persisted.name = url.deletingPathExtension().lastPathComponent
        persisted.type = type.rawValue
        persisted.mimeType = mime
        persisted.localPath = destination.path
        persisted.fileSize = size
        persisted.isPrimary = false
        persisted.tagsData = Data()
        persisted.createdAt = .now
        persisted.updatedAt = .now
        modelContext.insert(persisted)
        try modelContext.save()
        return mapToDomain(persisted)
    }

    func deleteDocument(id: UUID) async throws {
        let descriptor = FetchDescriptor<PersistedDocument>(predicate: #Predicate { $0.id == id })
        guard let doc = try modelContext.fetch(descriptor).first else { return }
        try fileProtection.deleteSecurely(at: URL(fileURLWithPath: doc.localPath))
        modelContext.delete(doc)
        try modelContext.save()
    }

    func setPrimaryDocument(id: UUID, type: DocumentType) async throws {
        let all = try modelContext.fetch(FetchDescriptor<PersistedDocument>())
        for doc in all where doc.type == type.rawValue {
            doc.isPrimary = doc.id == id
        }
        try modelContext.save()
    }

    func exportDocument(id: UUID) async throws -> URL {
        let descriptor = FetchDescriptor<PersistedDocument>(predicate: #Predicate { $0.id == id })
        guard let doc = try modelContext.fetch(descriptor).first else {
            throw DocumentError.notFound
        }
        return URL(fileURLWithPath: doc.localPath)
    }

    func uploadDocument(id: UUID, progress: (@Sendable (Double) -> Void)?) async throws -> URL {
        let localURL = try await exportDocument(id: id)
        progress?(1.0)
        return localURL
    }

    private func mapToDomain(_ doc: PersistedDocument) -> UserDocument {
        UserDocument(
            id: doc.id,
            name: doc.name,
            type: DocumentType(rawValue: doc.type) ?? .other,
            mimeType: doc.mimeType,
            localURL: URL(fileURLWithPath: doc.localPath),
            remoteURL: doc.remotePath.flatMap(URL.init(string:)),
            fileSize: doc.fileSize,
            isPrimary: doc.isPrimary,
            tags: (try? JSONDecoder().decode([String].self, from: doc.tagsData)) ?? [],
            createdAt: doc.createdAt,
            updatedAt: doc.updatedAt
        )
    }
}

enum DocumentError: Error {
    case notFound
}