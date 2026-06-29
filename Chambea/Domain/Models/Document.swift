import Foundation

struct UserDocument: Identifiable, Hashable, Sendable {
    let id: UUID
    var name: String
    var type: DocumentType
    var mimeType: String
    var localURL: URL
    var remoteURL: URL?
    var fileSize: Int64
    var isPrimary: Bool
    var tags: [String]
    var createdAt: Date
    var updatedAt: Date
}

enum DocumentType: String, Codable, CaseIterable, Sendable {
    case cv
    case coverLetter = "cover_letter"
    case portfolio
    case image
    case video
    case certificate
    case other

    var displayName: String {
        switch self {
        case .cv: return String(localized: "document.cv")
        case .coverLetter: return String(localized: "document.coverLetter")
        case .portfolio: return String(localized: "document.portfolio")
        case .image: return String(localized: "document.image")
        case .video: return String(localized: "document.video")
        case .certificate: return String(localized: "document.certificate")
        case .other: return String(localized: "document.other")
        }
    }

    var systemImage: String {
        switch self {
        case .cv, .coverLetter, .certificate: return "doc.text.fill"
        case .portfolio: return "folder.fill"
        case .image: return "photo.fill"
        case .video: return "video.fill"
        case .other: return "doc.fill"
        }
    }
}