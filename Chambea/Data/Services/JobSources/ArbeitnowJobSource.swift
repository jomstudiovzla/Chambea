import Foundation

final class ArbeitnowJobSource: JobSourceProtocol, @unchecked Sendable {
    let source: JobSource = .arbeitnow
    let isEnabled = true
    private let client: APIClientProtocol

    init(client: APIClientProtocol) {
        self.client = client
    }

    func fetchJobs(query: String?) async throws -> [Job] {
        let endpoint = Endpoint(baseURL: Endpoint.arbeitnow)
        let response = try await client.request(endpoint, responseType: ArbeitnowJobsResponse.self)
        let jobs = response.data.map(JobMapper.map)
        guard let query, !query.isEmpty else { return jobs }
        let q = query.lowercased()
        return jobs.filter {
            $0.title.lowercased().contains(q) || $0.company.lowercased().contains(q)
        }
    }
}