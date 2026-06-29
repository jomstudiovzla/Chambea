import Foundation

final class JobSourceAggregator: @unchecked Sendable {
    private let sources: [JobSourceProtocol]

    init(sources: [JobSourceProtocol]) {
        self.sources = sources
    }

    func fetchAll(query: String?) async throws -> [Job] {
        try await withThrowingTaskGroup(of: [Job].self) { group in
            for source in sources where source.isEnabled {
                group.addTask {
                    do {
                        return try await source.fetchJobs(query: query)
                    } catch {
                        return []
                    }
                }
            }
            var allJobs: [Job] = []
            for try await batch in group {
                allJobs.append(contentsOf: batch)
            }
            return deduplicate(allJobs.map(JobLanguageDetector.enrich))
        }
    }

    private func deduplicate(_ jobs: [Job]) -> [Job] {
        var seen = Set<String>()
        return jobs.filter { job in
            let key = "\(job.title.lowercased())-\(job.company.lowercased())"
            return seen.insert(key).inserted
        }
    }
}