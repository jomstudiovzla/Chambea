import Foundation
import SwiftData

@MainActor
final class ProfileRepository: ProfileRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func getProfile() async throws -> UserProfile? {
        let descriptor = FetchDescriptor<PersistedProfile>()
        guard let persisted = try modelContext.fetch(descriptor).first else { return nil }
        return try JSONDecoder().decode(UserProfile.self, from: persisted.profileData)
    }

    func saveProfile(_ profile: UserProfile) async throws {
        let data = try JSONEncoder().encode(profile)
        let descriptor = FetchDescriptor<PersistedProfile>()
        if let existing = try modelContext.fetch(descriptor).first {
            existing.profileData = data
            existing.updatedAt = .now
        } else {
            let persisted = PersistedProfile()
            persisted.id = profile.id
            persisted.profileData = data
            persisted.updatedAt = .now
            modelContext.insert(persisted)
        }
        try modelContext.save()
    }
}