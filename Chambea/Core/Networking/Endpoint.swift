import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

struct Endpoint: Sendable {
    let baseURL: URL
    let path: String
    let method: HTTPMethod
    let queryItems: [URLQueryItem]
    let headers: [String: String]
    let body: Data?

    init(
        baseURL: URL,
        path: String = "",
        method: HTTPMethod = .get,
        queryItems: [URLQueryItem] = [],
        headers: [String: String] = [:],
        body: Data? = nil
    ) {
        self.baseURL = baseURL
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.headers = headers
        self.body = body
    }
}

extension Endpoint {
    static let remotive = URL(string: "https://remotive.com/api/remote-jobs")!
    static let arbeitnow = URL(string: "https://arbeitnow.com/api/job-board-api")!
    static let remoteOK = URL(string: "https://remoteok.com/api")!
    static let jobicy = URL(string: "https://jobicy.com/api/v2/remote-jobs")!
    static let weWorkRemotely = URL(string: "https://weworkremotely.com/remote-jobs.rss")!
}