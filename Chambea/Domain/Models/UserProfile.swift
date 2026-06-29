import Foundation

struct UserProfile: Identifiable, Sendable {
    let id: UUID
    var fullName: String
    var headline: String
    var bio: String
    var location: String
    var profilePhotoURL: URL?
    var preferredCountries: [String]
    var preferredLanguages: [String]
    var skills: [String]
    var experienceYears: Int
    var linkedInURL: URL?
    var portfolioURL: URL?
    var websiteURL: URL?
    var githubURL: URL?
    var gitlabURL: URL?
    var youtubeURL: URL?
    var behanceURL: URL?
    var customLinks: [PortfolioLink]
    var targetRoles: [String]
    var salaryExpectationMin: Int?
    var salaryExpectationMax: Int?
    var salaryCurrency: String
    var updatedAt: Date

    var completionPercentage: Int {
        var score = 0
        if !fullName.trimmingCharacters(in: .whitespaces).isEmpty { score += 25 }
        if !headline.trimmingCharacters(in: .whitespaces).isEmpty { score += 20 }
        if profilePhotoURL != nil { score += 20 }
        if !bio.trimmingCharacters(in: .whitespaces).isEmpty { score += 20 }
        if !skills.isEmpty { score += 10 }
        if hasPortfolioLinks { score += 10 }
        return min(score, 100)
    }

    var hasPortfolioLinks: Bool {
        websiteURL != nil || githubURL != nil || gitlabURL != nil ||
        youtubeURL != nil || behanceURL != nil || portfolioURL != nil ||
        linkedInURL != nil || !customLinks.contains(where: { $0.url != nil })
    }

    enum CodingKeys: String, CodingKey {
        case id, fullName, headline, bio, location, profilePhotoURL
        case preferredCountries, preferredLanguages, skills, experienceYears
        case linkedInURL, portfolioURL, websiteURL, githubURL, gitlabURL
        case youtubeURL, behanceURL, customLinks, targetRoles
        case salaryExpectationMin, salaryExpectationMax, salaryCurrency, updatedAt
    }
}

extension UserProfile: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        fullName = try container.decode(String.self, forKey: .fullName)
        headline = try container.decode(String.self, forKey: .headline)
        bio = try container.decode(String.self, forKey: .bio)
        location = try container.decode(String.self, forKey: .location)
        profilePhotoURL = try container.decodeIfPresent(URL.self, forKey: .profilePhotoURL)
        preferredCountries = try container.decode([String].self, forKey: .preferredCountries)
        preferredLanguages = try container.decode([String].self, forKey: .preferredLanguages)
        skills = try container.decode([String].self, forKey: .skills)
        experienceYears = try container.decode(Int.self, forKey: .experienceYears)
        linkedInURL = try container.decodeIfPresent(URL.self, forKey: .linkedInURL)
        portfolioURL = try container.decodeIfPresent(URL.self, forKey: .portfolioURL)
        websiteURL = try container.decodeIfPresent(URL.self, forKey: .websiteURL)
        githubURL = try container.decodeIfPresent(URL.self, forKey: .githubURL)
        gitlabURL = try container.decodeIfPresent(URL.self, forKey: .gitlabURL)
        youtubeURL = try container.decodeIfPresent(URL.self, forKey: .youtubeURL)
        behanceURL = try container.decodeIfPresent(URL.self, forKey: .behanceURL)
        customLinks = try container.decodeIfPresent([PortfolioLink].self, forKey: .customLinks) ?? []
        targetRoles = try container.decode([String].self, forKey: .targetRoles)
        salaryExpectationMin = try container.decodeIfPresent(Int.self, forKey: .salaryExpectationMin)
        salaryExpectationMax = try container.decodeIfPresent(Int.self, forKey: .salaryExpectationMax)
        salaryCurrency = try container.decode(String.self, forKey: .salaryCurrency)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(fullName, forKey: .fullName)
        try container.encode(headline, forKey: .headline)
        try container.encode(bio, forKey: .bio)
        try container.encode(location, forKey: .location)
        try container.encodeIfPresent(profilePhotoURL, forKey: .profilePhotoURL)
        try container.encode(preferredCountries, forKey: .preferredCountries)
        try container.encode(preferredLanguages, forKey: .preferredLanguages)
        try container.encode(skills, forKey: .skills)
        try container.encode(experienceYears, forKey: .experienceYears)
        try container.encodeIfPresent(linkedInURL, forKey: .linkedInURL)
        try container.encodeIfPresent(portfolioURL, forKey: .portfolioURL)
        try container.encodeIfPresent(websiteURL, forKey: .websiteURL)
        try container.encodeIfPresent(githubURL, forKey: .githubURL)
        try container.encodeIfPresent(gitlabURL, forKey: .gitlabURL)
        try container.encodeIfPresent(youtubeURL, forKey: .youtubeURL)
        try container.encodeIfPresent(behanceURL, forKey: .behanceURL)
        try container.encode(customLinks, forKey: .customLinks)
        try container.encode(targetRoles, forKey: .targetRoles)
        try container.encodeIfPresent(salaryExpectationMin, forKey: .salaryExpectationMin)
        try container.encodeIfPresent(salaryExpectationMax, forKey: .salaryExpectationMax)
        try container.encode(salaryCurrency, forKey: .salaryCurrency)
        try container.encode(updatedAt, forKey: .updatedAt)
    }
}

extension UserProfile {
    static var empty: UserProfile {
        UserProfile(
            id: UUID(),
            fullName: "",
            headline: "",
            bio: "",
            location: "Venezuela",
            profilePhotoURL: nil,
            preferredCountries: ["ES", "VE", "MX"],
            preferredLanguages: ["es", "en"],
            skills: [],
            experienceYears: 0,
            customLinks: [],
            targetRoles: [],
            salaryCurrency: "USD",
            updatedAt: .now
        )
    }
}