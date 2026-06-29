import Foundation

protocol ProfileRepositoryProtocol: Sendable {
    func getProfile() async throws -> UserProfile?
    func saveProfile(_ profile: UserProfile) async throws
}