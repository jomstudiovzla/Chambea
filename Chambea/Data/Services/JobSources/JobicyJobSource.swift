import Foundation

final class JobicyJobSource: JobSourceProtocol, @unchecked Sendable {
    let source: JobSource = .jobicy
    let isEnabled = true
    private let client: APIClientProtocol

    init(client: APIClientProtocol) {
        self.client = client
    }

    func fetchJobs(query: String?) async throws -> [Job] {
        var items: [URLQueryItem] = [URLQueryItem(name: "count", value: "50")]
        if let query, !query.isEmpty {
            items.append(URLQueryItem(name: "tag", value: query))
        }
        let endpoint = Endpoint(baseURL: Endpoint.jobicy, queryItems: items)
        let response = try await client.request(endpoint, responseType: JobicyJobsResponse.self)
        var jobs = response.jobs.map(JobMapper.map)
        if let query, !query.isEmpty {
            let q = query.lowercased()
            jobs = jobs.filter {
                $0.title.lowercased().contains(q) ||
                $0.company.lowercased().contains(q) ||
                $0.description.lowercased().contains(q)
            }
        }
        return jobs.map(JobLanguageDetector.enrich)
    }
}