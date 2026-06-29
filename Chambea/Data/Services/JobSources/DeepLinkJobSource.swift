import Foundation

struct JobPortal: Sendable {
    let source: JobSource
    let title: String
    let company: String
    let description: String
    let searchURL: URL
    let languages: [String]
    let markets: [String]
    let tags: [String]
}

final class DeepLinkJobSource: JobSourceProtocol, @unchecked Sendable {
    let source: JobSource
    let isEnabled = true
    private let portal: JobPortal

    init(portal: JobPortal) {
        self.source = portal.source
        self.portal = portal
    }

    func fetchJobs(query: String?) async throws -> [Job] {
        var url = portal.searchURL
        if let query, !query.isEmpty,
           var components = URLComponents(url: portal.searchURL, resolvingAgainstBaseURL: false) {
            var items = components.queryItems ?? []
            items.append(URLQueryItem(name: "keywords", value: query))
            components.queryItems = items
            if let built = components.url { url = built }
        }

        let job = Job(
            id: "portal-\(source.rawValue)",
            title: portal.title,
            company: portal.company,
            description: portal.description,
            location: String(localized: "market.global"),
            country: nil,
            isRemote: true,
            remoteType: .fullyRemote,
            salaryMin: nil,
            salaryMax: nil,
            salaryCurrency: nil,
            seniority: .unknown,
            industry: String(localized: "source.portal"),
            contractType: .unknown,
            languages: portal.languages,
            tags: portal.tags + [String(localized: "source.portal")],
            source: source,
            sourceURL: url,
            applyURL: url,
            publishedAt: .now,
            logoURL: nil
        )
        return [job]
    }
}

enum JobPortals {
    static let all: [JobPortal] = [
        JobPortal(
            source: .linkedIn,
            title: String(localized: "portal.linkedin.title"),
            company: "LinkedIn",
            description: String(localized: "portal.linkedin.description"),
            searchURL: URL(string: "https://www.linkedin.com/jobs/search?keywords=remoto%20español&f_WT=2")!,
            languages: ["es", "en"],
            markets: ["global", "latam", "ES"],
            tags: ["Español", "Remoto", "Global"]
        ),
        JobPortal(
            source: .computrabajo,
            title: String(localized: "portal.computrabajo.title"),
            company: "Computrabajo",
            description: String(localized: "portal.computrabajo.description"),
            searchURL: URL(string: "https://www.computrabajo.com/trabajo-de-teletrabajo")!,
            languages: ["es"],
            markets: ["latam", "VE", "AR", "CL", "PE", "BO", "CO", "MX"],
            tags: ["Español", "LATAM", "Teletrabajo"]
        ),
        JobPortal(
            source: .bumeran,
            title: String(localized: "portal.bumeran.title"),
            company: "Bumeran",
            description: String(localized: "portal.bumeran.description"),
            searchURL: URL(string: "https://www.bumeran.com.ar/empleos-busqueda-trabajo-remoto.html")!,
            languages: ["es"],
            markets: ["latam", "AR", "CL", "PE", "BO"],
            tags: ["Español", "LATAM", "Remoto"]
        ),
        JobPortal(
            source: .infoJobs,
            title: String(localized: "portal.infojobs.title"),
            company: "InfoJobs",
            description: String(localized: "portal.infojobs.description"),
            searchURL: URL(string: "https://www.infojobs.net/ofertas-trabajo/teletrabajo")!,
            languages: ["es"],
            markets: ["ES", "eu"],
            tags: ["Español", "España", "Teletrabajo"]
        ),
        JobPortal(
            source: .torre,
            title: String(localized: "portal.torre.title"),
            company: "Torre.co",
            description: String(localized: "portal.torre.description"),
            searchURL: URL(string: "https://torre.co/jobs?compensationperiodicity=monthly&currency=USD&remote=true")!,
            languages: ["es", "en"],
            markets: ["latam", "global"],
            tags: ["Español", "LATAM", "Remoto"]
        )
    ]
}