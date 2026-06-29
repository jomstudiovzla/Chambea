import Foundation

struct SearchJobsUseCase: Sendable {
    let repository: JobRepositoryProtocol

    func execute(filter: JobFilter) async throws -> [Job] {
        let jobs = try await repository.searchJobs(filter: filter)
        let filtered = jobs.filter { filter.matches($0) }
        return sort(jobs: filtered, by: filter.sortBy)
    }

    private func sort(jobs: [Job], by option: JobSortOption) -> [Job] {
        switch option {
        case .newest:
            return jobs.sorted { $0.publishedAt > $1.publishedAt }
        case .salaryHigh:
            return jobs.sorted { ($0.salaryMax ?? $0.salaryMin ?? 0) > ($1.salaryMax ?? $1.salaryMin ?? 0) }
        case .relevance:
            return jobs
        }
    }
}