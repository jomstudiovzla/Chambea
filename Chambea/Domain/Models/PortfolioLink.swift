import Foundation

struct PortfolioLink: Identifiable, Codable, Sendable, Hashable {
    let id: UUID
    var title: String
    var urlString: String

    init(id: UUID = UUID(), title: String = "", urlString: String = "") {
        self.id = id
        self.title = title
        self.urlString = urlString
    }

    var url: URL? {
        guard !urlString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        var normalized = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        if !normalized.contains("://") {
            normalized = "https://\(normalized)"
        }
        return URL(string: normalized)
    }
}