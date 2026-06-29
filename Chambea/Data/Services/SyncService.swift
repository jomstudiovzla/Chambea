import Foundation
import SwiftData
import Network

protocol SyncServiceProtocol: Sendable {
    func enqueue(entityType: String, entityId: String, action: String, payload: Data?) async throws
    func syncPendingItems() async throws
    var isOnline: Bool { get async }
}

@MainActor
final class SyncService: SyncServiceProtocol {
    private let modelContext: ModelContext
    private let monitor = NWPathMonitor()
    private var online = true

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.online = path.status == .satisfied
                if path.status == .satisfied {
                    try? await self?.syncPendingItems()
                }
            }
        }
        monitor.start(queue: DispatchQueue(label: "com.chambea.network.monitor"))
    }

    var isOnline: Bool { online }

    func enqueue(entityType: String, entityId: String, action: String, payload: Data?) async throws {
        let item = SyncQueueItem()
        item.id = UUID()
        item.entityType = entityType
        item.entityId = entityId
        item.action = action
        item.payload = payload
        item.createdAt = .now
        item.retryCount = 0
        modelContext.insert(item)
        try modelContext.save()
    }

    func syncPendingItems() async throws {
        guard online else { return }
        let descriptor = FetchDescriptor<SyncQueueItem>()
        let items = try modelContext.fetch(descriptor)
        for item in items {
            modelContext.delete(item)
        }
        try modelContext.save()
    }
}