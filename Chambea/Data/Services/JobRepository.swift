import Foundation
import SwiftData

@MainActor
final class JobRepository: JobRepositoryProtocol {
    private let aggregator: JobSourceAggregator
    private let modelContext: ModelContext

    init(aggregator: JobSourceAggregator, modelContext: ModelContext) {
        self.aggregator = aggregator
        self.modelContext = modelContext
    }

    func searchJobs(filter: JobFilter) async throws -> [Job] {
        let jobs = try await aggregator.fetchAll(query: filter.query.isEmpty ? nil : filter.query)
        cache(jobs: jobs)
        return jobs
    }

    func getJob(id: String) async throws -> Job? {
        let descriptor = FetchDescriptor<PersistedJob>(predicate: #Predicate { $0.id == id })
        return try modelContext.fetch(descriptor).first?.toDomain()
    }

    func saveJob(_ job: Job, status: ApplicationStatus) async throws {
        let descriptor = FetchDescriptor<PersistedJob>(predicate: #Predicate { $0.id == job.id })
        if let existing = try modelContext.fetch(descriptor).first {
            existing.status = status.rawValue
            existing.savedAt = .now
            existing.notes = existing.notes ?? ""
        } else {
            let persisted = PersistedJob(from: job)
            persisted.status = status.rawValue
            persisted.savedAt = .now
            modelContext.insert(persisted)
        }
        try modelContext.save()
    }

    func getSavedJobs() async throws -> [SavedJob] {
        let descriptor = FetchDescriptor<PersistedJob>(predicate: #Predicate { $0.savedAt != nil })
        return try modelContext.fetch(descriptor).compactMap { persisted in
            guard let savedAt = persisted.savedAt else { return nil }
            return SavedJob(
                id: persisted.id,
                job: persisted.toDomain(),
                status: ApplicationStatus(rawValue: persisted.status ?? "saved") ?? .saved,
                notes: persisted.notes ?? "",
                savedAt: savedAt,
                updatedAt: savedAt
            )
        }
    }

    func updateSavedJobStatus(id: String, status: ApplicationStatus) async throws {
        let descriptor = FetchDescriptor<PersistedJob>(predicate: #Predicate { $0.id == id })
        guard let job = try modelContext.fetch(descriptor).first else { return }
        job.status = status.rawValue
        try modelContext.save()
    }

    func removeSavedJob(id: String) async throws {
        let descriptor = FetchDescriptor<PersistedJob>(predicate: #Predicate { $0.id == id })
        if let job = try modelContext.fetch(descriptor).first {
            job.savedAt = nil
            job.status = nil
            try modelContext.save()
        }
    }

    func getCachedJobs() async throws -> [Job] {
        let descriptor = FetchDescriptor<PersistedJob>()
        return try modelContext.fetch(descriptor).map { $0.toDomain() }
    }

    private func cache(jobs: [Job]) {
        for job in jobs {
            let jobId = job.id
            let descriptor = FetchDescriptor<PersistedJob>(predicate: #Predicate { $0.id == jobId })
            if (try? modelContext.fetch(descriptor).first) == nil {
                modelContext.insert(PersistedJob(from: job))
            }
        }
        try? modelContext.save()
    }
}