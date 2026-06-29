import Foundation

protocol AlertRepositoryProtocol: Sendable {
    func getAlerts() async throws -> [JobAlert]
    func createAlert(_ alert: JobAlert) async throws
    func updateAlert(_ alert: JobAlert) async throws
    func deleteAlert(id: UUID) async throws
}