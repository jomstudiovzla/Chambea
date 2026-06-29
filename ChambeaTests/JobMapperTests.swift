import XCTest
@testable import Chambea

final class JobMapperTests: XCTestCase {
    func testRemotiveMapping() {
        let dto = RemotiveJobDTO(
            id: 42,
            title: "Senior iOS Engineer",
            companyName: "Remote Co",
            description: "Build apps",
            candidateRequiredLocation: "Worldwide",
            jobType: "full_time",
            salary: "$80,000",
            publicationDate: "2026-01-15T00:00:00Z",
            url: "https://remotive.com/job/42",
            tags: ["Swift", "iOS"],
            companyLogo: nil
        )
        let job = JobMapper.map(dto)
        XCTAssertEqual(job.id, "remotive-42")
        XCTAssertEqual(job.title, "Senior iOS Engineer")
        XCTAssertTrue(job.isRemote)
        XCTAssertEqual(job.source, .remotive)
    }
}