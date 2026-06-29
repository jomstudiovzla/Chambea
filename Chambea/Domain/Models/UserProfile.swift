import Foundation

struct UserProfile: Identifiable, Sendable {
    let id: UUID
    var fullName: String
    var headline: String
    var headlineES: String
    var headlineEN: String
    var bio: String
    var aboutShortES: String
    var aboutShortEN: String
    var aboutLongES: String
    var aboutLongEN: String
    var location: String
    var timeZoneIdentifier: String
    var availability: [WorkAvailability]
    var profilePhotoURL: URL?
    var preferredCountries: [String]
    var preferredLanguages: [String]
    var skills: [String]
    var experienceYears: Int
    var experiences: [ExperienceEntry]
    var education: [EducationEntry]
    var certifications: [CertificationEntry]
    var languageSkills: [LanguageSkill]
    var socialLinks: [SocialLink]
    var linkedInURL: URL?
    var portfolioURL: URL?
    var websiteURL: URL?
    var githubURL: URL?
    var gitlabURL: URL?
    var youtubeURL: URL?
    var behanceURL: URL?
    var customLinks: [PortfolioLink]
    var presentationVideoURL: URL?
    var presentationVideoLanguage: PresentationVideoLanguage
    var targetRoles: [String]
    var salaryExpectationMin: Int?
    var salaryExpectationMax: Int?
    var salaryCurrency: String
    var updatedAt: Date

    var completionPercentage: Int {
        let sections = ProfileHubSection.allCases
        let completed = sections.filter { $0.status(for: self) == .complete }.count
        let partial = sections.filter { $0.status(for: self) == .partial }.count
        let score = (completed * 100 + partial * 50) / max(sections.count, 1)
        return min(score, 100)
    }

    var hasPortfolioLinks: Bool {
        websiteURL != nil || githubURL != nil || gitlabURL != nil ||
        youtubeURL != nil || behanceURL != nil || portfolioURL != nil ||
        linkedInURL != nil || !customLinks.contains(where: { $0.url != nil })
    }

    enum CodingKeys: String, CodingKey {
        case id, fullName, headline, headlineES, headlineEN, bio
        case aboutShortES, aboutShortEN, aboutLongES, aboutLongEN
        case location, timeZoneIdentifier, availability, profilePhotoURL
        case preferredCountries, preferredLanguages, skills, experienceYears
        case experiences, education, certifications, languageSkills, socialLinks
        case linkedInURL, portfolioURL, websiteURL, githubURL, gitlabURL
        case youtubeURL, behanceURL, customLinks, presentationVideoURL
        case presentationVideoLanguage, targetRoles
        case salaryExpectationMin, salaryExpectationMax, salaryCurrency, updatedAt
    }
}

extension UserProfile: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        fullName = try container.decode(String.self, forKey: .fullName)
        headline = try container.decode(String.self, forKey: .headline)
        headlineES = try container.decodeIfPresent(String.self, forKey: .headlineES) ?? headline
        headlineEN = try container.decodeIfPresent(String.self, forKey: .headlineEN) ?? ""
        bio = try container.decode(String.self, forKey: .bio)
        aboutShortES = try container.decodeIfPresent(String.self, forKey: .aboutShortES) ?? ""
        aboutShortEN = try container.decodeIfPresent(String.self, forKey: .aboutShortEN) ?? ""
        aboutLongES = try container.decodeIfPresent(String.self, forKey: .aboutLongES) ?? bio
        aboutLongEN = try container.decodeIfPresent(String.self, forKey: .aboutLongEN) ?? ""
        location = try container.decode(String.self, forKey: .location)
        timeZoneIdentifier = try container.decodeIfPresent(String.self, forKey: .timeZoneIdentifier) ?? "America/Caracas"
        availability = try container.decodeIfPresent([WorkAvailability].self, forKey: .availability) ?? []
        profilePhotoURL = try container.decodeIfPresent(URL.self, forKey: .profilePhotoURL)
        preferredCountries = try container.decode([String].self, forKey: .preferredCountries)
        preferredLanguages = try container.decode([String].self, forKey: .preferredLanguages)
        skills = try container.decode([String].self, forKey: .skills)
        experienceYears = try container.decode(Int.self, forKey: .experienceYears)
        experiences = try container.decodeIfPresent([ExperienceEntry].self, forKey: .experiences) ?? []
        education = try container.decodeIfPresent([EducationEntry].self, forKey: .education) ?? []
        certifications = try container.decodeIfPresent([CertificationEntry].self, forKey: .certifications) ?? []
        languageSkills = try container.decodeIfPresent([LanguageSkill].self, forKey: .languageSkills) ?? []
        socialLinks = try container.decodeIfPresent([SocialLink].self, forKey: .socialLinks) ?? []
        linkedInURL = try container.decodeIfPresent(URL.self, forKey: .linkedInURL)
        portfolioURL = try container.decodeIfPresent(URL.self, forKey: .portfolioURL)
        websiteURL = try container.decodeIfPresent(URL.self, forKey: .websiteURL)
        githubURL = try container.decodeIfPresent(URL.self, forKey: .githubURL)
        gitlabURL = try container.decodeIfPresent(URL.self, forKey: .gitlabURL)
        youtubeURL = try container.decodeIfPresent(URL.self, forKey: .youtubeURL)
        behanceURL = try container.decodeIfPresent(URL.self, forKey: .behanceURL)
        customLinks = try container.decodeIfPresent([PortfolioLink].self, forKey: .customLinks) ?? []
        presentationVideoURL = try container.decodeIfPresent(URL.self, forKey: .presentationVideoURL)
        presentationVideoLanguage = try container.decodeIfPresent(PresentationVideoLanguage.self, forKey: .presentationVideoLanguage) ?? .spanish
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
        try container.encode(headlineES, forKey: .headlineES)
        try container.encode(headlineEN, forKey: .headlineEN)
        try container.encode(bio, forKey: .bio)
        try container.encode(aboutShortES, forKey: .aboutShortES)
        try container.encode(aboutShortEN, forKey: .aboutShortEN)
        try container.encode(aboutLongES, forKey: .aboutLongES)
        try container.encode(aboutLongEN, forKey: .aboutLongEN)
        try container.encode(location, forKey: .location)
        try container.encode(timeZoneIdentifier, forKey: .timeZoneIdentifier)
        try container.encode(availability, forKey: .availability)
        try container.encodeIfPresent(profilePhotoURL, forKey: .profilePhotoURL)
        try container.encode(preferredCountries, forKey: .preferredCountries)
        try container.encode(preferredLanguages, forKey: .preferredLanguages)
        try container.encode(skills, forKey: .skills)
        try container.encode(experienceYears, forKey: .experienceYears)
        try container.encode(experiences, forKey: .experiences)
        try container.encode(education, forKey: .education)
        try container.encode(certifications, forKey: .certifications)
        try container.encode(languageSkills, forKey: .languageSkills)
        try container.encode(socialLinks, forKey: .socialLinks)
        try container.encodeIfPresent(linkedInURL, forKey: .linkedInURL)
        try container.encodeIfPresent(portfolioURL, forKey: .portfolioURL)
        try container.encodeIfPresent(websiteURL, forKey: .websiteURL)
        try container.encodeIfPresent(githubURL, forKey: .githubURL)
        try container.encodeIfPresent(gitlabURL, forKey: .gitlabURL)
        try container.encodeIfPresent(youtubeURL, forKey: .youtubeURL)
        try container.encodeIfPresent(behanceURL, forKey: .behanceURL)
        try container.encode(customLinks, forKey: .customLinks)
        try container.encodeIfPresent(presentationVideoURL, forKey: .presentationVideoURL)
        try container.encode(presentationVideoLanguage, forKey: .presentationVideoLanguage)
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
            headlineES: "",
            headlineEN: "",
            bio: "",
            aboutShortES: "",
            aboutShortEN: "",
            aboutLongES: "",
            aboutLongEN: "",
            location: "Venezuela",
            timeZoneIdentifier: "America/Caracas",
            availability: [.remote],
            profilePhotoURL: nil,
            preferredCountries: ["ES", "VE", "MX"],
            preferredLanguages: ["es", "en"],
            skills: [],
            experienceYears: 0,
            experiences: [],
            education: [],
            certifications: [],
            languageSkills: [],
            socialLinks: [],
            customLinks: [],
            presentationVideoLanguage: .spanish,
            targetRoles: [],
            salaryCurrency: "USD",
            updatedAt: .now
        )
    }
}