import Foundation

enum WorkAvailability: String, Codable, CaseIterable, Sendable {
    case remote
    case hybrid
    case onsite

    var displayName: String {
        switch self {
        case .remote: String(localized: "profile.availability.remote")
        case .hybrid: String(localized: "profile.availability.hybrid")
        case .onsite: String(localized: "profile.availability.onsite")
        }
    }
}

enum LanguageLevel: String, Codable, CaseIterable, Sendable {
    case a1, a2, b1, b2, c1, c2, native

    var displayName: String {
        rawValue.uppercased()
    }
}

enum ContactVisibility: String, Codable, CaseIterable, Sendable {
    case `public`
    case applyOnly
    case `private`

    var displayName: String {
        switch self {
        case .public: String(localized: "profile.visibility.public")
        case .applyOnly: String(localized: "profile.visibility.applyOnly")
        case .private: String(localized: "profile.visibility.private")
        }
    }
}

enum PresentationVideoLanguage: String, Codable, CaseIterable, Sendable {
    case spanish
    case english
    case bilingual

    var displayName: String {
        switch self {
        case .spanish: String(localized: "profile.video.language.spanish")
        case .english: String(localized: "profile.video.language.english")
        case .bilingual: String(localized: "profile.video.language.bilingual")
        }
    }
}

enum ProfileSectionStatus: Sendable {
    case empty
    case partial
    case complete

    var displayName: String {
        switch self {
        case .empty: String(localized: "profile.section.empty")
        case .partial: String(localized: "profile.section.partial")
        case .complete: String(localized: "profile.section.complete")
        }
    }
}

struct ExperienceEntry: Identifiable, Codable, Sendable, Hashable {
    var id: UUID
    var title: String
    var company: String
    var startDate: Date
    var endDate: Date?
    var isCurrent: Bool
    var isRemoteOrInternational: Bool
    var description: String
    var achievements: String
    var sectors: [String]

    init(
        id: UUID = UUID(),
        title: String = "",
        company: String = "",
        startDate: Date = .now,
        endDate: Date? = nil,
        isCurrent: Bool = false,
        isRemoteOrInternational: Bool = false,
        description: String = "",
        achievements: String = "",
        sectors: [String] = []
    ) {
        self.id = id
        self.title = title
        self.company = company
        self.startDate = startDate
        self.endDate = endDate
        self.isCurrent = isCurrent
        self.isRemoteOrInternational = isRemoteOrInternational
        self.description = description
        self.achievements = achievements
        self.sectors = sectors
    }
}

struct EducationEntry: Identifiable, Codable, Sendable, Hashable {
    var id: UUID
    var institution: String
    var degree: String
    var startDate: Date
    var endDate: Date?
    var country: String

    init(
        id: UUID = UUID(),
        institution: String = "",
        degree: String = "",
        startDate: Date = .now,
        endDate: Date? = nil,
        country: String = ""
    ) {
        self.id = id
        self.institution = institution
        self.degree = degree
        self.startDate = startDate
        self.endDate = endDate
        self.country = country
    }
}

struct CertificationEntry: Identifiable, Codable, Sendable, Hashable {
    var id: UUID
    var name: String
    var issuer: String
    var issuedAt: Date
    var expiresAt: Date?
    var verificationURL: URL?

    init(
        id: UUID = UUID(),
        name: String = "",
        issuer: String = "",
        issuedAt: Date = .now,
        expiresAt: Date? = nil,
        verificationURL: URL? = nil
    ) {
        self.id = id
        self.name = name
        self.issuer = issuer
        self.issuedAt = issuedAt
        self.expiresAt = expiresAt
        self.verificationURL = verificationURL
    }
}

struct LanguageSkill: Identifiable, Codable, Sendable, Hashable {
    var id: UUID
    var language: String
    var level: LanguageLevel

    init(id: UUID = UUID(), language: String = "es", level: LanguageLevel = .b2) {
        self.id = id
        self.language = language
        self.level = level
    }
}

struct SocialLink: Identifiable, Codable, Sendable, Hashable {
    var id: UUID
    var platform: String
    var urlString: String
    var visibility: ContactVisibility

    init(
        id: UUID = UUID(),
        platform: String = "",
        urlString: String = "",
        visibility: ContactVisibility = .public
    ) {
        self.id = id
        self.platform = platform
        self.urlString = urlString
        self.visibility = visibility
    }

    var url: URL? {
        guard !urlString.isEmpty else { return nil }
        let normalized = urlString.hasPrefix("http") ? urlString : "https://\(urlString)"
        return URL(string: normalized)
    }
}

enum ProfileHubSection: String, CaseIterable, Identifiable, Sendable {
    case basicInfo
    case about
    case experience
    case education
    case skills
    case portfolio
    case socialContact
    case presentationVideo

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .basicInfo: "person.crop.circle"
        case .about: "text.alignleft"
        case .experience: "briefcase.fill"
        case .education: "graduationcap.fill"
        case .skills: "star.fill"
        case .portfolio: "link"
        case .socialContact: "person.2.fill"
        case .presentationVideo: "video.fill"
        }
    }

    var title: String {
        switch self {
        case .basicInfo: String(localized: "profile.section.basic")
        case .about: String(localized: "profile.section.about")
        case .experience: String(localized: "profile.section.experience")
        case .education: String(localized: "profile.section.education")
        case .skills: String(localized: "profile.section.skills")
        case .portfolio: String(localized: "profile.portfolio")
        case .socialContact: String(localized: "profile.section.social")
        case .presentationVideo: String(localized: "profile.section.video")
        }
    }

    func status(for profile: UserProfile) -> ProfileSectionStatus {
        switch self {
        case .basicInfo:
            let filled = [
                !profile.fullName.isEmpty,
                !profile.headlineES.isEmpty || !profile.headline.isEmpty,
                profile.profilePhotoURL != nil,
                !profile.location.isEmpty
            ].filter { $0 }.count
            if filled == 0 { return .empty }
            return filled >= 3 ? .complete : .partial
        case .about:
            let hasShort = !profile.aboutShortES.isEmpty || !profile.aboutShortEN.isEmpty
            let hasLong = !profile.aboutLongES.isEmpty || !profile.aboutLongEN.isEmpty || !profile.bio.isEmpty
            if !hasShort && !hasLong { return .empty }
            return hasShort && hasLong ? .complete : .partial
        case .experience:
            if profile.experiences.isEmpty { return .empty }
            let complete = profile.experiences.contains { !$0.title.isEmpty && !$0.company.isEmpty }
            return complete ? .complete : .partial
        case .education:
            if profile.education.isEmpty && profile.certifications.isEmpty { return .empty }
            let hasData = profile.education.contains { !$0.institution.isEmpty } ||
                profile.certifications.contains { !$0.name.isEmpty }
            return hasData ? .complete : .partial
        case .skills:
            if profile.skills.isEmpty && profile.languageSkills.isEmpty { return .empty }
            return (!profile.skills.isEmpty && !profile.languageSkills.isEmpty) ? .complete : .partial
        case .portfolio:
            return profile.hasPortfolioLinks ? .complete : .empty
        case .socialContact:
            let filled = profile.socialLinks.filter { !$0.urlString.isEmpty }.count
            if filled == 0 { return .empty }
            return filled >= 2 ? .complete : .partial
        case .presentationVideo:
            return profile.presentationVideoURL != nil ? .complete : .empty
        }
    }
}