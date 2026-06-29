import Foundation

enum JobLanguage: String, CaseIterable, Codable, Sendable {
    case spanish = "es"
    case english = "en"
    case bilingual
    case portuguese = "pt"
    case any

    var displayName: String {
        switch self {
        case .spanish: return String(localized: "language.spanish")
        case .english: return String(localized: "language.english")
        case .bilingual: return String(localized: "language.bilingual")
        case .portuguese: return String(localized: "language.portuguese")
        case .any: return String(localized: "language.any")
        }
    }

    var code: String? {
        switch self {
        case .spanish: return "es"
        case .english: return "en"
        case .portuguese: return "pt"
        case .bilingual, .any: return nil
        }
    }
}

enum TargetMarket: String, CaseIterable, Codable, Sendable {
    case venezuela = "VE"
    case latam
    case spain = "ES"
    case eu
    case usa = "US"
    case canada = "CA"
    case asia
    case europe
    case russia
    case africa
    case global

    var displayName: String {
        switch self {
        case .venezuela: return String(localized: "market.venezuela")
        case .latam: return String(localized: "market.latam")
        case .spain: return String(localized: "market.spain")
        case .eu: return String(localized: "market.eu")
        case .usa: return String(localized: "market.usa")
        case .canada: return String(localized: "market.canada")
        case .asia: return String(localized: "market.asia")
        case .europe: return String(localized: "market.europe")
        case .russia: return String(localized: "market.russia")
        case .africa: return String(localized: "market.africa")
        case .global: return String(localized: "market.global")
        }
    }

    static let latamCountries: Set<String> = [
        "VE", "AR", "CL", "PE", "BO", "CO", "MX", "EC", "UY", "PY",
        "CR", "PA", "GT", "HN", "SV", "NI", "DO", "PR", "CU", "BR"
    ]
}