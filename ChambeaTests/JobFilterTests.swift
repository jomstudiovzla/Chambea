import XCTest
@testable import Chambea

final class JobFilterTests: XCTestCase {
    func testMatchesRemoteOnly() {
        let filter = JobFilter(remoteOnly: true)
        let remoteJob = makeJob(isRemote: true)
        let onsiteJob = makeJob(isRemote: false)
        XCTAssertTrue(filter.matches(remoteJob))
        XCTAssertFalse(filter.matches(onsiteJob))
    }

    func testMatchesQuery() {
        var filter = JobFilter()
        filter.query = "swift"
        let job = makeJob(title: "iOS Swift Developer")
        XCTAssertTrue(filter.matches(job))
    }

    private func makeJob(title: String = "Developer", isRemote: Bool = true) -> Job {
        Job(
            id: "test-1",
            title: title,
            company: "Acme",
            description: "Remote iOS role",
            location: "Remote",
            country: "US",
            isRemote: isRemote,
            remoteType: .fullyRemote,
            salaryMin: 50000,
            salaryMax: 80000,
            salaryCurrency: "USD",
            seniority: .mid,
            industry: "Tech",
            contractType: .fullTime,
            languages: ["en"],
            tags: ["Swift"],
            source: .remotive,
            sourceURL: URL(string: "https://example.com")!,
            applyURL: nil,
            publishedAt: .now,
            logoURL: nil
        )
    }
}