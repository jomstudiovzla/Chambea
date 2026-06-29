import Foundation

protocol APIClientProtocol: Sendable {
    func request<T: Decodable>(_ endpoint: Endpoint, responseType: T.Type) async throws -> T
    func requestData(_ endpoint: Endpoint) async throws -> Data
    func download(from url: URL, progress: (@Sendable (Double) -> Void)?) async throws -> URL
    func upload(data: Data, to endpoint: Endpoint, progress: (@Sendable (Double) -> Void)?) async throws -> Data
}

final class APIClient: APIClientProtocol, @unchecked Sendable {
    private let session: URLSession
    private let retryPolicy: RetryPolicy
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, retryPolicy: RetryPolicy = RetryPolicy()) {
        self.session = session
        self.retryPolicy = retryPolicy
        self.decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
    }

    func request<T: Decodable>(_ endpoint: Endpoint, responseType: T.Type) async throws -> T {
        let data = try await requestData(endpoint)
        return try decoder.decode(T.self, from: data)
    }

    func requestData(_ endpoint: Endpoint) async throws -> Data {
        try await retryPolicy.execute {
            let request = try RequestBuilder.build(from: endpoint)
            let (data, response) = try await session.data(for: request)
            try Self.validate(response: response, data: data)
            return data
        }
    }

    func download(from url: URL, progress: (@Sendable (Double) -> Void)? = nil) async throws -> URL {
        let (tempURL, response) = try await session.download(from: url)
        try Self.validate(response: response, data: nil)
        let destination = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.moveItem(at: tempURL, to: destination)
        progress?(1.0)
        return destination
    }

    func upload(data: Data, to endpoint: Endpoint, progress: (@Sendable (Double) -> Void)? = nil) async throws -> Data {
        try await retryPolicy.execute {
            var request = try RequestBuilder.build(from: endpoint)
            request.httpBody = data
            let (responseData, response) = try await session.data(for: request)
            try Self.validate(response: response, data: responseData)
            progress?(1.0)
            return responseData
        }
    }

    private static func validate(response: URLResponse, data: Data?) throws {
        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        switch http.statusCode {
        case 200...299: return
        case 401: throw NetworkError.unauthorized
        case 429: throw NetworkError.rateLimited
        default:
            let message = data.flatMap { String(data: $0, encoding: .utf8) }
            throw NetworkError.serverError(statusCode: http.statusCode, message: message)
        }
    }
}