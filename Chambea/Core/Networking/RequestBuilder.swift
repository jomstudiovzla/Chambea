import Foundation

enum RequestBuilder {
    static func build(from endpoint: Endpoint) throws -> URLRequest {
        guard var components = URLComponents(url: endpoint.baseURL, resolvingAgainstBaseURL: true) else {
            throw NetworkError.invalidURL
        }
        if !endpoint.path.isEmpty {
            components.path = endpoint.path.hasPrefix("/") ? endpoint.path : "/\(endpoint.path)"
        }
        if !endpoint.queryItems.isEmpty {
            components.queryItems = endpoint.queryItems
        }
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        endpoint.headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        return request
    }
}