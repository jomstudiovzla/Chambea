import Foundation

final class RemoteOKJobSource: JobSourceProtocol, @unchecked Sendable {
    let source: JobSource = .remoteOK
    let isEnabled = true
    private let client: APIClientProtocol

    init(client: APIClientProtocol) {
        self.client = client
    }

    func fetchJobs(query: String?) async throws -> [Job] {
        let endpoint = Endpoint(baseURL: Endpoint.remoteOK)
        let dtos = try await client.request(endpoint, responseType: [RemoteOKJobDTO].self)
        var jobs: [Job] = []
        for (index, dto) in dtos.enumerated() {
            if let job = JobMapper.map(dto, index: index) {
                jobs.append(job)
            }
        }
        guard let query, !query.isEmpty else { return jobs }
        let q = query.lowercased()
        return jobs.filter {
            $0.title.lowercased().contains(q) || $0.company.lowercased().contains(q)
        }
    }
}