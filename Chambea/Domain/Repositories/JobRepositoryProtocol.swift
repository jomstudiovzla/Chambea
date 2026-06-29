import Foundation

protocol JobRepositoryProtocol: Sendable {
    func searchJobs(filter: JobFilter) async throws -> [Job]
    func getJob(id: String) async throws -> Job?
    func saveJob(_ job: Job, status: ApplicationStatus) async throws
    func getSavedJobs() async throws -> [SavedJob]
    func updateSavedJobStatus(id: String, status: ApplicationStatus) async throws
    func removeSavedJob(id: String) async throws
    func getCachedJobs() async throws -> [Job]
}