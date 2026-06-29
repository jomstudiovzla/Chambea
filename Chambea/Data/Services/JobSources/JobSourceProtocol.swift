import Foundation

protocol JobSourceProtocol: Sendable {
    var source: JobSource { get }
    var isEnabled: Bool { get }
    func fetchJobs(query: String?) async throws -> [Job]
}