import Foundation

struct RemotiveJobsResponse: Decodable {
    let jobs: [RemotiveJobDTO]
}

struct RemotiveJobDTO: Decodable {
    let id: Int
    let title: String
    let companyName: String
    let description: String
    let candidateRequiredLocation: String?
    let jobType: String?
    let salary: String?
    let publicationDate: String
    let url: String
    let tags: [String]?
    let companyLogo: String?
}

struct ArbeitnowJobsResponse: Decodable {
    let data: [ArbeitnowJobDTO]
}

struct ArbeitnowJobDTO: Decodable {
    let slug: String
    let title: String
    let companyName: String
    let description: String
    let remote: Bool
    let url: String
    let tags: [String]?
    let createdAt: Int?
}

struct JobicyJobsResponse: Decodable {
    let jobs: [JobicyJobDTO]
}

struct JobicyJobDTO: Decodable {
    let id: Int
    let url: String
    let jobTitle: String
    let companyName: String
    let companyLogo: String?
    let jobIndustry: [String]?
    let jobType: [String]?
    let jobGeo: String?
    let jobLevel: String?
    let jobExcerpt: String?
    let jobDescription: String?
    let pubDate: String
}

struct RemoteOKJobDTO: Decodable {
    let id: String?
    let position: String?
    let company: String?
    let description: String?
    let location: String?
    let url: String?
    let tags: [String]?
    let date: String?
    let logo: String?
}