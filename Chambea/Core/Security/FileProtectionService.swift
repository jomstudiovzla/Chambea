import Foundation

protocol FileProtectionServiceProtocol: Sendable {
    func secureDirectory() throws -> URL
    func protectFile(at url: URL) throws
    func deleteSecurely(at url: URL) throws
}

final class FileProtectionService: FileProtectionServiceProtocol, @unchecked Sendable {
    private let fileManager = FileManager.default

    func secureDirectory() throws -> URL {
        let url = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("ChambeaDocuments", isDirectory: true)
        if !fileManager.fileExists(atPath: url.path) {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        }
        try protectFile(at: url)
        return url
    }

    func protectFile(at url: URL) throws {
        try fileManager.setAttributes(
            [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication],
            ofItemAtPath: url.path
        )
    }

    func deleteSecurely(at url: URL) throws {
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
    }
}