import Foundation
import SwiftData

@MainActor
final class AlertRepository: AlertRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func getAlerts() async throws -> [JobAlert] {
        let descriptor = FetchDescriptor<PersistedAlert>()
        return try modelContext.fetch(descriptor).compactMap { persisted in
            guard let filter = try? JSONDecoder().decode(JobFilter.self, from: persisted.filterData) else { return nil }
            return JobAlert(
                id: persisted.id,
                name: persisted.name,
                filter: filter,
                isEnabled: persisted.isEnabled,
                frequency: AlertFrequency(rawValue: persisted.frequency) ?? .daily,
                lastTriggeredAt: persisted.lastTriggeredAt,
                createdAt: persisted.createdAt
            )
        }
    }

    func createAlert(_ alert: JobAlert) async throws {
        let persisted = PersistedAlert()
        persisted.id = alert.id
        persisted.name = alert.name
        persisted.filterData = (try? JSONEncoder().encode(alert.filter)) ?? Data()
        persisted.isEnabled = alert.isEnabled
        persisted.frequency = alert.frequency.rawValue
        persisted.lastTriggeredAt = alert.lastTriggeredAt
        persisted.createdAt = alert.createdAt
        modelContext.insert(persisted)
        try modelContext.save()
    }

    func updateAlert(_ alert: JobAlert) async throws {
        let alertId = alert.id
        let descriptor = FetchDescriptor<PersistedAlert>(predicate: #Predicate { $0.id == alertId })
        guard let persisted = try modelContext.fetch(descriptor).first else { return }
        persisted.name = alert.name
        persisted.filterData = (try? JSONEncoder().encode(alert.filter)) ?? Data()
        persisted.isEnabled = alert.isEnabled
        persisted.frequency = alert.frequency.rawValue
        persisted.lastTriggeredAt = alert.lastTriggeredAt
        try modelContext.save()
    }

    func deleteAlert(id: UUID) async throws {
        let descriptor = FetchDescriptor<PersistedAlert>(predicate: #Predicate { $0.id == id })
        if let alert = try modelContext.fetch(descriptor).first {
            modelContext.delete(alert)
            try modelContext.save()
        }
    }
}