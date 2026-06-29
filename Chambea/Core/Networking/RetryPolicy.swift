import Foundation

struct RetryPolicy: Sendable {
    let maxAttempts: Int
    let baseDelay: TimeInterval

    init(maxAttempts: Int = 3, baseDelay: TimeInterval = 1.0) {
        self.maxAttempts = maxAttempts
        self.baseDelay = baseDelay
    }

    func execute<T>(_ operation: @Sendable () async throws -> T) async throws -> T {
        var lastError: Error?
        for attempt in 0..<maxAttempts {
            do {
                return try await operation()
            } catch let error as NetworkError where error.isRetryable {
                lastError = error
                if attempt < maxAttempts - 1 {
                    let delay = baseDelay * pow(2.0, Double(attempt))
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            } catch {
                throw error
            }
        }
        throw lastError ?? NetworkError.invalidResponse
    }
}