import Foundation

enum JobMapper {
    static func map(_ dto: RemotiveJobDTO) -> Job {
        Job(
            id: "remotive-\(dto.id)",
            title: dto.title,
            company: dto.companyName,
            description: dto.description,
            location: dto.candidateRequiredLocation ?? "Remote",
            country: nil,
            isRemote: true,
            remoteType: .fullyRemote,
            salaryMin: parseSalaryMin(dto.salary),
            salaryMax: parseSalaryMax(dto.salary),
            salaryCurrency: "USD",
            seniority: inferSeniority(from: dto.title, tags: dto.tags ?? []),
            industry: dto.tags?.first,
            contractType: mapContractType(dto.jobType),
            languages: ["en"],
            tags: dto.tags ?? [],
            source: .remotive,
            sourceURL: URL(string: dto.url) ?? Endpoint.remotive,
            applyURL: URL(string: dto.url),
            publishedAt: ISO8601DateFormatter().date(from: dto.publicationDate) ?? .now,
            logoURL: dto.companyLogo.flatMap(URL.init(string:))
        )
    }

    static func map(_ dto: ArbeitnowJobDTO) -> Job {
        Job(
            id: "arbeitnow-\(dto.slug)",
            title: dto.title,
            company: dto.companyName,
            description: dto.description,
            location: "Remote",
            country: nil,
            isRemote: dto.remote,
            remoteType: dto.remote ? .fullyRemote : .unknown,
            salaryMin: nil,
            salaryMax: nil,
            salaryCurrency: nil,
            seniority: inferSeniority(from: dto.title, tags: dto.tags ?? []),
            industry: dto.tags?.first,
            contractType: .unknown,
            languages: ["en", "de"],
            tags: dto.tags ?? [],
            source: .arbeitnow,
            sourceURL: URL(string: dto.url) ?? Endpoint.arbeitnow,
            applyURL: URL(string: dto.url),
            publishedAt: dto.createdAt.map { Date(timeIntervalSince1970: TimeInterval($0)) } ?? .now,
            logoURL: nil
        )
    }

    static func map(_ dto: JobicyJobDTO) -> Job {
        let description = dto.jobDescription ?? dto.jobExcerpt ?? ""
        let tags = (dto.jobIndustry ?? []) + (dto.jobType ?? [])
        let languages = JobLanguageDetector.detectLanguageCodes(in: "\(dto.jobTitle) \(description)")
        return Job(
            id: "jobicy-\(dto.id)",
            title: dto.jobTitle,
            company: dto.companyName,
            description: description,
            location: dto.jobGeo ?? "Remote",
            country: nil,
            isRemote: true,
            remoteType: .fullyRemote,
            salaryMin: nil,
            salaryMax: nil,
            salaryCurrency: nil,
            seniority: inferSeniority(from: dto.jobTitle, tags: tags),
            industry: dto.jobIndustry?.first,
            contractType: mapContractType(dto.jobType?.first),
            languages: languages.isEmpty ? ["en"] : languages,
            tags: tags,
            source: .jobicy,
            sourceURL: URL(string: dto.url) ?? Endpoint.jobicy,
            applyURL: URL(string: dto.url),
            publishedAt: ISO8601DateFormatter().date(from: dto.pubDate) ?? .now,
            logoURL: dto.companyLogo.flatMap(URL.init(string:))
        )
    }

    static func map(_ dto: RemoteOKJobDTO, index: Int) -> Job? {
        guard let title = dto.position, let company = dto.company, let url = dto.url else { return nil }
        return Job(
            id: "remoteok-\(dto.id ?? "\(index)")",
            title: title,
            company: company,
            description: dto.description ?? "",
            location: dto.location ?? "Remote",
            country: nil,
            isRemote: true,
            remoteType: .fullyRemote,
            salaryMin: nil,
            salaryMax: nil,
            salaryCurrency: nil,
            seniority: inferSeniority(from: title, tags: dto.tags ?? []),
            industry: dto.tags?.first,
            contractType: .unknown,
            languages: ["en"],
            tags: dto.tags ?? [],
            source: .remoteOK,
            sourceURL: URL(string: url) ?? Endpoint.remoteOK,
            applyURL: URL(string: url),
            publishedAt: .now,
            logoURL: dto.logo.flatMap(URL.init(string:))
        )
    }

    private static func parseSalaryMin(_ salary: String?) -> Int? {
        guard let salary else { return nil }
        let digits = salary.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return Int(digits.prefix(6))
    }

    private static func parseSalaryMax(_ salary: String?) -> Int? {
        parseSalaryMin(salary)
    }

    private static func inferSeniority(from title: String, tags: [String]) -> Seniority {
        let text = (title + " " + tags.joined(separator: " ")).lowercased()
        if text.contains("senior") || text.contains("sr.") { return .senior }
        if text.contains("lead") || text.contains("principal") { return .lead }
        if text.contains("junior") || text.contains("jr.") { return .junior }
        if text.contains("intern") { return .intern }
        if text.contains("mid") { return .mid }
        return .unknown
    }

    private static func mapContractType(_ type: String?) -> ContractType {
        guard let type else { return .unknown }
        let lower = type.lowercased()
        if lower.contains("full") { return .fullTime }
        if lower.contains("part") { return .partTime }
        if lower.contains("contract") { return .contract }
        return .unknown
    }
}