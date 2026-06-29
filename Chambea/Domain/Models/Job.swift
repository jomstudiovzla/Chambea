import Foundation

struct Job: Identifiable, Hashable, Codable, Sendable {
    let id: String
    let title: String
    let company: String
    let description: String
    let location: String
    let country: String?
    let isRemote: Bool
    let remoteType: RemoteType
    let salaryMin: Int?
    let salaryMax: Int?
    let salaryCurrency: String?
    let seniority: Seniority
    let industry: String?
    let contractType: ContractType
    let languages: [String]
    let tags: [String]
    let source: JobSource
    let sourceURL: URL
    let applyURL: URL?
    let publishedAt: Date
    let logoURL: URL?

    var salaryDisplay: String? {
        guard let min = salaryMin else { return nil }
        let currency = salaryCurrency ?? "USD"
        if let max = salaryMax {
            return "\(currency) \(min.formatted()) – \(max.formatted())"
        }
        return "\(currency) \(min.formatted())+"
    }
}

enum RemoteType: String, Codable, CaseIterable, Sendable {
    case fullyRemote = "fully_remote"
    case hybrid
    case timezoneRestricted = "timezone_restricted"
    case unknown

    var displayName: String {
        switch self {
        case .fullyRemote: return String(localized: "remote.fully")
        case .hybrid: return String(localized: "remote.hybrid")
        case .timezoneRestricted: return String(localized: "remote.timezone")
        case .unknown: return String(localized: "remote.unknown")
        }
    }
}

enum Seniority: String, Codable, CaseIterable, Sendable {
    case intern, junior, mid, senior, lead, executive, unknown

    var displayName: String {
        switch self {
        case .intern: return String(localized: "seniority.intern")
        case .junior: return String(localized: "seniority.junior")
        case .mid: return String(localized: "seniority.mid")
        case .senior: return String(localized: "seniority.senior")
        case .lead: return String(localized: "seniority.lead")
        case .executive: return String(localized: "seniority.executive")
        case .unknown: return String(localized: "seniority.unknown")
        }
    }
}

enum ContractType: String, Codable, CaseIterable, Sendable {
    case fullTime = "full_time"
    case partTime = "part_time"
    case contract
    case freelance
    case internship
    case unknown

    var displayName: String {
        switch self {
        case .fullTime: return String(localized: "contract.fullTime")
        case .partTime: return String(localized: "contract.partTime")
        case .contract: return String(localized: "contract.contract")
        case .freelance: return String(localized: "contract.freelance")
        case .internship: return String(localized: "contract.internship")
        case .unknown: return String(localized: "contract.unknown")
        }
    }
}

enum JobSource: String, Codable, CaseIterable, Sendable {
    case remotive
    case arbeitnow
    case remoteOK = "remote_ok"
    case findjobit
    case jobicy
    case weWorkRemotely = "weworkremotely"
    case linkedIn = "linkedin"
    case computrabajo
    case bumeran
    case infoJobs = "infojobs"
    case torre
    case partnership
    case manual

    var displayName: String {
        switch self {
        case .remotive: return "Remotive"
        case .arbeitnow: return "Arbeitnow"
        case .remoteOK: return "RemoteOK"
        case .findjobit: return "Findjobit"
        case .jobicy: return "Jobicy"
        case .weWorkRemotely: return "We Work Remotely"
        case .linkedIn: return "LinkedIn"
        case .computrabajo: return "Computrabajo"
        case .bumeran: return "Bumeran"
        case .infoJobs: return "InfoJobs"
        case .torre: return "Torre.co"
        case .partnership: return String(localized: "source.partnership")
        case .manual: return String(localized: "source.manual")
        }
    }

    var isPortal: Bool {
        switch self {
        case .linkedIn, .computrabajo, .bumeran, .infoJobs, .torre: return true
        default: return false
        }
    }
}