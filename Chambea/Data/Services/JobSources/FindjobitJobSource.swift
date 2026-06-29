import Foundation

final class FindjobitJobSource: JobSourceProtocol, @unchecked Sendable {
    let source: JobSource = .findjobit
    let isEnabled = true
    private let client: APIClientProtocol

    private let feedURLs: [URL] = [
        "https://findjobit.com/jobs/feed",
        "https://findjobit.com/jobs/country/chile/feed",
        "https://findjobit.com/jobs/country/argentina/feed",
        "https://findjobit.com/jobs/country/peru/feed",
        "https://findjobit.com/jobs/country/bolivia/feed",
        "https://findjobit.com/jobs/country/venezuela/feed",
        "https://findjobit.com/jobs/country/colombia/feed",
        "https://findjobit.com/jobs/country/mexico/feed",
        "https://findjobit.com/jobs/country/ecuador/feed",
        "https://findjobit.com/jobs/country/uruguay/feed"
    ].compactMap(URL.init(string:))

    init(client: APIClientProtocol) {
        self.client = client
    }

    func fetchJobs(query: String?) async throws -> [Job] {
        try await withThrowingTaskGroup(of: [Job].self) { group in
            for feedURL in feedURLs {
                group.addTask {
                    let source = RSSJobSource(
                        source: .findjobit,
                        feedURL: feedURL,
                        client: self.client,
                        defaultLanguage: "es"
                    )
                    return (try? await source.fetchJobs(query: query)) ?? []
                }
            }
            var all: [Job] = []
            for try await batch in group { all.append(contentsOf: batch) }
            return deduplicate(all)
        }
    }

    private func deduplicate(_ jobs: [Job]) -> [Job] {
        var seen = Set<String>()
        return jobs.filter { seen.insert($0.id).inserted }
    }
}