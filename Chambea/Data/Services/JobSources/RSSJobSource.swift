import Foundation

struct RSSJobItem: Sendable {
    let guid: String
    let title: String
    let link: URL
    let description: String
    let category: String?
    let region: String?
    let type: String?
    let pubDate: Date
}

final class RSSJobSource: JobSourceProtocol, @unchecked Sendable {
    let source: JobSource
    let isEnabled: Bool
    private let feedURL: URL
    private let client: APIClientProtocol
    private let defaultLanguage: String

    init(
        source: JobSource,
        feedURL: URL,
        client: APIClientProtocol,
        defaultLanguage: String = "es",
        isEnabled: Bool = true
    ) {
        self.source = source
        self.feedURL = feedURL
        self.client = client
        self.defaultLanguage = defaultLanguage
        self.isEnabled = isEnabled
    }

    func fetchJobs(query: String?) async throws -> [Job] {
        let endpoint = Endpoint(baseURL: feedURL)
        let data = try await client.requestData(endpoint)
        let items = RSSParser.parse(data: data)
        var jobs = items.map { map($0) }
        if let query, !query.isEmpty {
            let q = query.lowercased()
            jobs = jobs.filter {
                $0.title.lowercased().contains(q) ||
                $0.company.lowercased().contains(q) ||
                $0.description.lowercased().contains(q)
            }
        }
        return jobs.map(JobLanguageDetector.enrich)
    }

    private func map(_ item: RSSJobItem) -> Job {
        let company = extractCompany(from: item.title)
        let isRemote = item.description.lowercased().contains("remoto") ||
            item.description.lowercased().contains("remote") ||
            item.type?.lowercased().contains("remoto") == true
        let country = item.region.flatMap(countryCode)
        return Job(
            id: "\(source.rawValue)-\(item.guid)",
            title: extractTitle(from: item.title, company: company),
            company: company,
            description: item.description,
            location: item.region ?? "Remoto",
            country: country,
            isRemote: isRemote,
            remoteType: isRemote ? .fullyRemote : .unknown,
            salaryMin: nil,
            salaryMax: nil,
            salaryCurrency: nil,
            seniority: .unknown,
            industry: item.category,
            contractType: mapContract(item.type),
            languages: [defaultLanguage],
            tags: [item.category, item.region, item.type].compactMap { $0 }.filter { !$0.isEmpty },
            source: source,
            sourceURL: item.link,
            applyURL: item.link,
            publishedAt: item.pubDate,
            logoURL: nil
        )
    }

    private func extractCompany(from title: String) -> String {
        let separators = [" busca un ", " busca una ", " busca "]
        for sep in separators where title.lowercased().contains(sep) {
            return title.components(separatedBy: sep).first?.trimmingCharacters(in: .whitespaces) ?? title
        }
        return title.components(separatedBy: " - ").first?.trimmingCharacters(in: .whitespaces) ?? title
    }

    private func extractTitle(from raw: String, company: String) -> String {
        let separators = [" busca un ", " busca una ", " busca "]
        for sep in separators where raw.lowercased().contains(sep) {
            let parts = raw.components(separatedBy: sep)
            if parts.count > 1 {
                return parts[1].trimmingCharacters(in: .whitespaces)
            }
        }
        return raw.replacingOccurrences(of: company, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func mapContract(_ type: String?) -> ContractType {
        guard let type else { return .unknown }
        let lower = type.lowercased()
        if lower.contains("completo") || lower.contains("full") { return .fullTime }
        if lower.contains("parcial") || lower.contains("part") { return .partTime }
        if lower.contains("freelance") { return .freelance }
        return .unknown
    }

    private func countryCode(from region: String) -> String? {
        let mapping: [String: String] = [
            "Venezuela": "VE", "Chile": "CL", "Argentina": "AR", "Perú": "PE", "Peru": "PE",
            "Bolivia": "BO", "Colombia": "CO", "México": "MX", "Mexico": "MX",
            "Ecuador": "EC", "Uruguay": "UY", "Paraguay": "PY", "Brasil": "BR", "Brazil": "BR",
            "Guatemala": "GT", "Honduras": "HN", "Nicaragua": "NI", "Panamá": "PA", "Panama": "PA",
            "Costa Rica": "CR", "República Dominicana": "DO", "Puerto Rico": "PR", "Cuba": "CU",
            "España": "ES", "Spain": "ES"
        ]
        return mapping[region]
    }
}

enum RSSParser {
    static func parse(data: Data) -> [RSSJobItem] {
        let delegate = RSSParserDelegate()
        let parser = XMLParser(data: data)
        parser.delegate = delegate
        parser.parse()
        return delegate.items
    }
}

private final class RSSParserDelegate: NSObject, XMLParserDelegate {
    var items: [RSSJobItem] = []
    private var currentElement = ""
    private var currentTitle = ""
    private var currentLink = ""
    private var currentDescription = ""
    private var currentCategory = ""
    private var currentRegion = ""
    private var currentType = ""
    private var currentPubDate = ""
    private var currentGUID = ""
    private var isInsideItem = false

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName: String?, attributes attributeDict: [String: String] = [:]) {
        currentElement = elementName
        if elementName == "item" {
            isInsideItem = true
            currentTitle = ""
            currentLink = ""
            currentDescription = ""
            currentCategory = ""
            currentRegion = ""
            currentType = ""
            currentPubDate = ""
            currentGUID = ""
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard isInsideItem else { return }
        switch currentElement {
        case "title": currentTitle += string
        case "link": currentLink += string
        case "description": currentDescription += string
        case "category": currentCategory += string
        case "region": currentRegion += string
        case "type": currentType += string
        case "pubDate": currentPubDate += string
        case "guid": currentGUID += string
        default: break
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName: String?) {
        guard elementName == "item", isInsideItem else { return }
        isInsideItem = false
        guard let link = URL(string: currentLink.trimmingCharacters(in: .whitespacesAndNewlines)) else { return }
        let guid = currentGUID.trimmingCharacters(in: .whitespacesAndNewlines)
        items.append(RSSJobItem(
            guid: guid.isEmpty ? link.absoluteString : guid,
            title: currentTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            link: link,
            description: currentDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            category: currentCategory.isEmpty ? nil : currentCategory.trimmingCharacters(in: .whitespacesAndNewlines),
            region: currentRegion.isEmpty ? nil : currentRegion.trimmingCharacters(in: .whitespacesAndNewlines),
            type: currentType.isEmpty ? nil : currentType.trimmingCharacters(in: .whitespacesAndNewlines),
            pubDate: parseDate(currentPubDate) ?? .now
        ))
    }

    private func parseDate(_ value: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        return formatter.date(from: value.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}