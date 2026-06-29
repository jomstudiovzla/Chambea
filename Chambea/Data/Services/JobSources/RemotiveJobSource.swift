import Foundation

final class RemotiveJobSource: JobSourceProtocol, @unchecked Sendable {
    let source: JobSource = .remotive
    let isEnabled = true
    private let client: APIClientProtocol

    init(client: APIClientProtocol) {
        self.client = client
    }

    func fetchJobs(query: String?) async throws -> [Job] {
        var items: [URLQueryItem] = []
        if let query, !query.isEmpty {
            items.append(URLQueryItem(name: "search", value: query))
        }
        let endpoint = Endpoint(baseURL: Endpoint.remotive, queryItems: items)
        let response = try await client.request(endpoint, responseType: RemotiveJobsResponse.self)
        return response.jobs.map(JobMapper.map)
    }
}