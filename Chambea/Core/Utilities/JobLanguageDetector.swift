import Foundation

enum JobLanguageDetector {
    private static let spanishIndicators = [
        "español", "espanol", "spanish", "remoto", "teletrabajo", "vacante",
        "empresa", "experiencia", "requisitos", "responsabilidades", "sueldo",
        "salario", "contrato", "jornada", "postúlate", "postulate", "candidato",
        "desarrollador", "ingeniero", "analista", "gerente", "coordinador",
        "habilidades", "conocimientos", "beneficios", "ubicación", "país"
    ]

    private static let englishIndicators = [
        "english", "remote", "full-time", "part-time", "requirements",
        "responsibilities", "experience", "salary", "benefits", "apply now",
        "candidate", "developer", "engineer", "manager", "skills"
    ]

    private static let portugueseIndicators = [
        "português", "portugues", "remoto", "vaga", "empresa", "experiência",
        "requisitos", "responsabilidades", "salário", "candidato"
    ]

    private static let regionToMarket: [String: TargetMarket] = [
        "venezuela": .venezuela, "chile": .latam, "argentina": .latam,
        "perú": .latam, "peru": .latam, "bolivia": .latam, "colombia": .latam,
        "méxico": .latam, "mexico": .latam, "ecuador": .latam, "uruguay": .latam,
        "paraguay": .latam, "brasil": .latam, "brazil": .latam, "guatemala": .latam,
        "honduras": .latam, "nicaragua": .latam, "panamá": .latam, "panama": .latam,
        "costa rica": .latam, "república dominicana": .latam, "puerto rico": .latam,
        "cuba": .latam, "españa": .spain, "spain": .spain, "europe": .europe,
        "europa": .europe, "germany": .europe, "france": .europe, "uk": .europe,
        "united kingdom": .europe, "canada": .canada, "usa": .usa,
        "united states": .usa, "us": .usa, "asia": .asia, "india": .asia,
        "japan": .asia, "china": .asia, "russia": .russia, "africa": .africa
    ]

    static func detectLanguageCodes(in text: String) -> [String] {
        let lower = text.lowercased()
        var codes: Set<String> = []

        let spanishScore = score(lower, indicators: spanishIndicators) + accentedCharScore(lower)
        let englishScore = score(lower, indicators: englishIndicators)
        let portugueseScore = score(lower, indicators: portugueseIndicators)

        if spanishScore >= 2 { codes.insert("es") }
        if englishScore >= 2 { codes.insert("en") }
        if portugueseScore >= 2 { codes.insert("pt") }

        if codes.isEmpty {
            if spanishScore > englishScore && spanishScore > 0 { codes.insert("es") }
            else if englishScore > 0 { codes.insert("en") }
            else if portugueseScore > 0 { codes.insert("pt") }
        }

        return Array(codes)
    }

    static func categories(for job: Job) -> Set<JobLanguage> {
        let text = "\(job.title) \(job.description) \(job.tags.joined(separator: " ")) \(job.location)"
        let codes = Set(job.languages + detectLanguageCodes(in: text))

        var categories = Set<JobLanguage>()
        if codes.contains("es") && codes.contains("en") { categories.insert(.bilingual) }
        if codes.contains("es") { categories.insert(.spanish) }
        if codes.contains("en") { categories.insert(.english) }
        if codes.contains("pt") { categories.insert(.portuguese) }
        if categories.isEmpty { categories.insert(.any) }
        return categories
    }

    static func targetMarkets(for job: Job) -> Set<TargetMarket> {
        let text = "\(job.location) \(job.country ?? "") \(job.description) \(job.tags.joined(separator: " "))"
            .lowercased()
        var markets = Set<TargetMarket>()

        for (keyword, market) in regionToMarket where text.contains(keyword) {
            markets.insert(market)
        }

        if let country = job.country {
            if TargetMarket.latamCountries.contains(country) { markets.insert(.latam) }
            if country == "VE" { markets.insert(.venezuela) }
            if country == "ES" { markets.insert(.spain) }
            if country == "US" { markets.insert(.usa) }
            if country == "CA" { markets.insert(.canada) }
        }

        if job.isRemote && markets.isEmpty { markets.insert(.global) }
        return markets
    }

    static func enrich(_ job: Job) -> Job {
        let text = "\(job.title) \(job.description) \(job.tags.joined(separator: " "))"
        let detected = detectLanguageCodes(in: text)
        let merged = Array(Set(job.languages + detected))
        return Job(
            id: job.id,
            title: job.title,
            company: job.company,
            description: job.description,
            location: job.location,
            country: job.country ?? inferCountry(from: job.location),
            isRemote: job.isRemote,
            remoteType: job.remoteType,
            salaryMin: job.salaryMin,
            salaryMax: job.salaryMax,
            salaryCurrency: job.salaryCurrency,
            seniority: job.seniority,
            industry: job.industry,
            contractType: job.contractType,
            languages: merged.isEmpty ? job.languages : merged,
            tags: job.tags,
            source: job.source,
            sourceURL: job.sourceURL,
            applyURL: job.applyURL,
            publishedAt: job.publishedAt,
            logoURL: job.logoURL
        )
    }

    private static func score(_ text: String, indicators: [String]) -> Int {
        indicators.reduce(0) { $0 + (text.contains($1) ? 1 : 0) }
    }

    private static func accentedCharScore(_ text: String) -> Int {
        let accents = ["á", "é", "í", "ó", "ú", "ñ", "ü", "¿", "¡"]
        return accents.contains(where: text.contains) ? 2 : 0
    }

    private static func inferCountry(from location: String) -> String? {
        let lower = location.lowercased()
        let mapping: [String: String] = [
            "venezuela": "VE", "chile": "CL", "argentina": "AR", "perú": "PE", "peru": "PE",
            "bolivia": "BO", "colombia": "CO", "méxico": "MX", "mexico": "MX",
            "españa": "ES", "spain": "ES", "canada": "CA", "usa": "US",
            "united states": "US", "brasil": "BR", "brazil": "BR"
        ]
        for (keyword, code) in mapping where lower.contains(keyword) {
            return code
        }
        return nil
    }
}