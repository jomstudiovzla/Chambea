import Foundation

enum NetworkError: LocalizedError, Equatable {
    case invalidURL
    case invalidResponse
    case unauthorized
    case rateLimited
    case decodingFailed
    case noConnection
    case serverError(statusCode: Int, message: String?)
    case cancelled

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return String(localized: "error.network.invalidURL")
        case .invalidResponse:
            return String(localized: "error.network.invalidResponse")
        case .unauthorized:
            return String(localized: "error.network.unauthorized")
        case .rateLimited:
            return String(localized: "error.network.rateLimited")
        case .decodingFailed:
            return String(localized: "error.network.decodingFailed")
        case .noConnection:
            return String(localized: "error.network.noConnection")
        case .serverError(let code, let message):
            return message ?? String(localized: "error.network.server \(code)")
        case .cancelled:
            return String(localized: "error.network.cancelled")
        }
    }

    var isRetryable: Bool {
        switch self {
        case .rateLimited, .noConnection, .serverError: return true
        default: return false
        }
    }
}