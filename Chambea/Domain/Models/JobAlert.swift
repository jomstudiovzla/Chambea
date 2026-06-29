import Foundation

struct JobAlert: Identifiable, Sendable {
    let id: UUID
    var name: String
    var filter: JobFilter
    var isEnabled: Bool
    var frequency: AlertFrequency
    var lastTriggeredAt: Date?
    var createdAt: Date
}

enum AlertFrequency: String, Codable, CaseIterable, Sendable {
    case realtime
    case daily
    case weekly

    var displayName: String {
        switch self {
        case .realtime: return String(localized: "alert.realtime")
        case .daily: return String(localized: "alert.daily")
        case .weekly: return String(localized: "alert.weekly")
        }
    }
}