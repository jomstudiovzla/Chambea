import Foundation

@MainActor
final class DocumentsViewModel: ObservableObject {
    @Published var documents: [UserDocument] = []
    @Published var isLoading = false

    private let useCase = ManageDocumentsUseCase(repository: DIContainer.shared.documentRepository)

    func load() async {
        isLoading = true
        defer { isLoading = false }
        documents = (try? await DIContainer.shared.documentRepository.getDocuments()) ?? []
    }

    func importFile(from url: URL) async {
        if let doc = try? await useCase.importFile(from: url, type: inferType(url)) {
            documents.append(doc)
        }
    }

    func importPhotoData(_ data: Data) async {
        let temp = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).jpg")
        try? data.write(to: temp)
        await importFile(from: temp)
    }

    private func inferType(_ url: URL) -> DocumentType {
        let ext = url.pathExtension.lowercased()
        switch ext {
        case "pdf", "doc", "docx": return .cv
        case "png", "jpg", "jpeg": return .image
        case "mp4", "mov": return .video
        default: return .other
        }
    }
}