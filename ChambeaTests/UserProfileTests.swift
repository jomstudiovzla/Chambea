import XCTest
@testable import Chambea

final class UserProfileTests: XCTestCase {
    func testEmptyProfileCompletionIsLow() {
        let profile = UserProfile.empty
        XCTAssertLessThan(profile.completionPercentage, 25)
        XCTAssertEqual(ProfileHubSection.experience.status(for: profile), .empty)
        XCTAssertEqual(ProfileHubSection.presentationVideo.status(for: profile), .empty)
    }

    func testBasicInfoIncreasesCompletion() {
        var profile = UserProfile.empty
        profile.fullName = "María López"
        profile.headlineES = "Desarrolladora iOS"
        profile.location = "Caracas, Venezuela"
        profile.profilePhotoURL = URL(string: "file:///tmp/photo.jpg")
        XCTAssertGreaterThan(profile.completionPercentage, 0)
        XCTAssertEqual(ProfileHubSection.basicInfo.status(for: profile), .complete)
    }

    func testPortfolioSectionCompleteWithLinks() {
        var profile = UserProfile.empty
        profile.githubURL = URL(string: "https://github.com/test")
        XCTAssertEqual(ProfileHubSection.portfolio.status(for: profile), .complete)
    }

    func testCodableRoundTripPreservesNewFields() throws {
        var profile = UserProfile.empty
        profile.headlineES = "Ingeniera"
        profile.experiences = [ExperienceEntry(title: "Dev", company: "Acme")]
        profile.languageSkills = [LanguageSkill(language: "es", level: .native)]

        let data = try JSONEncoder().encode(profile)
        let decoded = try JSONDecoder().decode(UserProfile.self, from: data)

        XCTAssertEqual(decoded.headlineES, "Ingeniera")
        XCTAssertEqual(decoded.experiences.count, 1)
        XCTAssertEqual(decoded.languageSkills.first?.level, .native)
    }
}