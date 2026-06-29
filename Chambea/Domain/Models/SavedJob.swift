import Foundation

enum ApplicationStatus: String, Codable, CaseIterable, Sendable {
    case saved
    case applied
    case interviewing
    case offered
    case rejected
    case archived

    var displayName: String {
        switch self {
        case .saved: return String(localized: "status.saved")
        case .applied: return String(localized: "status.applied")
        case .interviewing: return String(localized: "status.interviewing")
        case .offered: return String(localized: "status.offered")
        case .rejected: return String(localized: "status.rejected")
        case .archived: return String(localized: "status.archived")
        }
    }
}

struct SavedJob: Identifiable, Hashable, Sendable {
    let id: String
    let job: Job
    var status: ApplicationStatus
    var notes: String
    var savedAt: Date
    var updatedAt: Date
}