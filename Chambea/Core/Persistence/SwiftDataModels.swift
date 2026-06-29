import Foundation
import SwiftData

@Model
final class PersistedJob {
    @Attribute(.unique) var id: String
    var title: String
    var company: String
    var jobDescription: String
    var location: String
    var country: String?
    var isRemote: Bool
    var remoteType: String
    var salaryMin: Int?
    var salaryMax: Int?
    var salaryCurrency: String?
    var seniority: String
    var industry: String?
    var contractType: String
    var languagesData: Data
    var tagsData: Data
    var source: String
    var sourceURL: String
    var applyURL: String?
    var publishedAt: Date
    var logoURL: String?
    var status: String?
    var notes: String?
    var savedAt: Date?
    var cachedAt: Date

    init(from job: Job, cachedAt: Date = .now) {
        self.id = job.id
        self.title = job.title
        self.company = job.company
        self.jobDescription = job.description
        self.location = job.location
        self.country = job.country
        self.isRemote = job.isRemote
        self.remoteType = job.remoteType.rawValue
        self.salaryMin = job.salaryMin
        self.salaryMax = job.salaryMax
        self.salaryCurrency = job.salaryCurrency
        self.seniority = job.seniority.rawValue
        self.industry = job.industry
        self.contractType = job.contractType.rawValue
        self.languagesData = (try? JSONEncoder().encode(job.languages)) ?? Data()
        self.tagsData = (try? JSONEncoder().encode(job.tags)) ?? Data()
        self.source = job.source.rawValue
        self.sourceURL = job.sourceURL.absoluteString
        self.applyURL = job.applyURL?.absoluteString
        self.publishedAt = job.publishedAt
        self.logoURL = job.logoURL?.absoluteString
        self.cachedAt = cachedAt
    }

    func toDomain() -> Job {
        let languages = (try? JSONDecoder().decode([String].self, from: languagesData)) ?? []
        let tags = (try? JSONDecoder().decode([String].self, from: tagsData)) ?? []
        return Job(
            id: id,
            title: title,
            company: company,
            description: jobDescription,
            location: location,
            country: country,
            isRemote: isRemote,
            remoteType: RemoteType(rawValue: remoteType) ?? .unknown,
            salaryMin: salaryMin,
            salaryMax: salaryMax,
            salaryCurrency: salaryCurrency,
            seniority: Seniority(rawValue: seniority) ?? .unknown,
            industry: industry,
            contractType: ContractType(rawValue: contractType) ?? .unknown,
            languages: languages,
            tags: tags,
            source: JobSource(rawValue: source) ?? .manual,
            sourceURL: URL(string: sourceURL) ?? URL(string: "https://chambea.app")!,
            applyURL: applyURL.flatMap(URL.init(string:)),
            publishedAt: publishedAt,
            logoURL: logoURL.flatMap(URL.init(string:))
        )
    }
}

@Model
final class PersistedDocument {
    @Attribute(.unique) var id: UUID
    var name: String
    var type: String
    var mimeType: String
    var localPath: String
    var remotePath: String?
    var fileSize: Int64
    var isPrimary: Bool
    var tagsData: Data
    var createdAt: Date
    var updatedAt: Date

    init() {
        self.id = UUID()
        self.name = ""
        self.type = ""
        self.mimeType = ""
        self.localPath = ""
        self.fileSize = 0
        self.isPrimary = false
        self.tagsData = Data()
        self.createdAt = .now
        self.updatedAt = .now
    }
}

@Model
final class PersistedAlert {
    @Attribute(.unique) var id: UUID
    var name: String
    var filterData: Data
    var isEnabled: Bool
    var frequency: String
    var lastTriggeredAt: Date?
    var createdAt: Date

    init() {
        self.id = UUID()
        self.name = ""
        self.filterData = Data()
        self.isEnabled = true
        self.frequency = AlertFrequency.daily.rawValue
        self.createdAt = .now
    }
}

@Model
final class PersistedProfile {
    @Attribute(.unique) var id: UUID
    var profileData: Data
    var updatedAt: Date

    init() {
        self.id = UUID()
        self.profileData = Data()
        self.updatedAt = .now
    }
}

@Model
final class SyncQueueItem {
    @Attribute(.unique) var id: UUID
    var entityType: String
    var entityId: String
    var action: String
    var payload: Data?
    var createdAt: Date
    var retryCount: Int

    init() {
        self.id = UUID()
        self.entityType = ""
        self.entityId = ""
        self.action = ""
        self.createdAt = .now
        self.retryCount = 0
    }
}