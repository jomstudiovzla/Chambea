import Foundation

struct JobFilter: Equatable, Sendable, Codable {
    var query: String = ""
    var countries: Set<String> = []
    var languages: Set<String> = []
    var jobLanguages: Set<JobLanguage> = []
    var targetMarkets: Set<TargetMarket> = []
    var remoteOnly: Bool = true
    var remoteTypes: Set<RemoteType> = []
    var salaryMin: Int?
    var salaryMax: Int?
    var seniorities: Set<Seniority> = []
    var industries: Set<String> = []
    var contractTypes: Set<ContractType> = []
    var sources: Set<JobSource> = Set(JobSource.allCases)
    var sortBy: JobSortOption = .newest

    var isActive: Bool {
        !query.isEmpty ||
        !countries.isEmpty ||
        !languages.isEmpty ||
        !jobLanguages.isEmpty ||
        !targetMarkets.isEmpty ||
        salaryMin != nil ||
        salaryMax != nil ||
        !seniorities.isEmpty ||
        !industries.isEmpty ||
        !contractTypes.isEmpty ||
        !remoteTypes.isEmpty
    }

    func matches(_ job: Job) -> Bool {
        if remoteOnly && !job.isRemote { return false }
        if !query.isEmpty {
            let q = query.lowercased()
            let haystack = "\(job.title) \(job.company) \(job.description) \(job.tags.joined(separator: " "))".lowercased()
            if !haystack.contains(q) { return false }
        }
        if !countries.isEmpty, let country = job.country, !countries.contains(country) { return false }
        if !languages.isEmpty, languages.isDisjoint(with: Set(job.languages)) { return false }
        if !jobLanguages.isEmpty {
            let categories = JobLanguageDetector.categories(for: job)
            if jobLanguages.isDisjoint(with: categories) && !categories.contains(.any) { return false }
        }
        if !targetMarkets.isEmpty {
            let markets = JobLanguageDetector.targetMarkets(for: job)
            if targetMarkets.isDisjoint(with: markets) && !markets.contains(.global) { return false }
        }
        if !remoteTypes.isEmpty, !remoteTypes.contains(job.remoteType) { return false }
        if let min = salaryMin, let jobMax = job.salaryMax, jobMax < min { return false }
        if let max = salaryMax, let jobMin = job.salaryMin, jobMin > max { return false }
        if !seniorities.isEmpty, !seniorities.contains(job.seniority) { return false }
        if !industries.isEmpty, let industry = job.industry, !industries.contains(industry) { return false }
        if !contractTypes.isEmpty, !contractTypes.contains(job.contractType) { return false }
        if !sources.isEmpty, !sources.contains(job.source) { return false }
        return true
    }
}

enum JobSortOption: String, CaseIterable, Sendable, Codable {
    case newest
    case salaryHigh
    case relevance

    var displayName: String {
        switch self {
        case .newest: return String(localized: "sort.newest")
        case .salaryHigh: return String(localized: "sort.salary")
        case .relevance: return String(localized: "sort.relevance")
        }
    }
}