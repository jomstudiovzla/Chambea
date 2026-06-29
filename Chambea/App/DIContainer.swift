import Foundation
import SwiftData

@MainActor
final class DIContainer {
    static let shared = DIContainer()

    let modelContainer: ModelContainer
    let apiClient: APIClient
    let keychainService: KeychainService
    let jobRepository: JobRepositoryProtocol
    let documentRepository: DocumentRepositoryProtocol
    let profileRepository: ProfileRepositoryProtocol
    let alertRepository: AlertRepositoryProtocol
    let aiService: AIServiceProtocol
    let notificationService: NotificationServiceProtocol
    let syncService: SyncServiceProtocol
    let fileProtectionService: FileProtectionServiceProtocol

    private init() {
        let schema = Schema([
            PersistedJob.self,
            PersistedDocument.self,
            PersistedAlert.self,
            PersistedProfile.self,
            SyncQueueItem.self
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: false)
        modelContainer = try! ModelContainer(for: schema, configurations: [config])

        apiClient = APIClient()
        keychainService = KeychainService()
        fileProtectionService = FileProtectionService()

        var jobSources: [JobSourceProtocol] = [
            FindjobitJobSource(client: apiClient),
            JobicyJobSource(client: apiClient),
            RemotiveJobSource(client: apiClient),
            ArbeitnowJobSource(client: apiClient),
            RemoteOKJobSource(client: apiClient),
            RSSJobSource(
                source: .weWorkRemotely,
                feedURL: Endpoint.weWorkRemotely,
                client: apiClient,
                defaultLanguage: "en"
            )
        ]
        jobSources += JobPortals.all.map { DeepLinkJobSource(portal: $0) }
        let jobSourceAggregator = JobSourceAggregator(sources: jobSources)

        jobRepository = JobRepository(
            aggregator: jobSourceAggregator,
            modelContext: modelContainer.mainContext
        )
        documentRepository = DocumentRepository(
            modelContext: modelContainer.mainContext,
            fileProtection: fileProtectionService
        )
        profileRepository = ProfileRepository(modelContext: modelContainer.mainContext)
        alertRepository = AlertRepository(modelContext: modelContainer.mainContext)
        aiService = AIService(client: apiClient, keychain: keychainService)
        notificationService = NotificationService()
        syncService = SyncService(modelContext: modelContainer.mainContext)
    }
}