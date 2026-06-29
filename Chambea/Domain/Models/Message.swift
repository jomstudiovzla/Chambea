import Foundation

struct RecruiterMessage: Identifiable, Sendable {
    let id: UUID
    let jobId: String
    let recruiterName: String?
    let subject: String
    let body: String
    let channel: MessageChannel
    let createdAt: Date
    var status: MessageStatus
}

enum MessageChannel: String, Codable, Sendable {
    case inApp = "in_app"
    case email
    case externalLink = "external_link"

    var displayName: String {
        switch self {
        case .inApp: return String(localized: "message.inApp")
        case .email: return String(localized: "message.email")
        case .externalLink: return String(localized: "message.external")
        }
    }
}

enum MessageStatus: String, Codable, Sendable {
    case draft
    case sent
    case failed
}