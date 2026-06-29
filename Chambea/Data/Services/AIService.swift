import Foundation

protocol AIServiceProtocol: Sendable {
    func generateCoverLetter(request: AICoverLetterRequest) async throws -> String
    func startInterview(job: Job, profile: UserProfile) async throws -> AIInterviewSession
    func submitInterviewAnswer(sessionId: UUID, questionId: UUID, answer: String) async throws -> String
    func optimizeForATS(cvText: String, job: Job) async throws -> ATSOptimizationResult
    func suggestAnswer(question: String, job: Job, profile: UserProfile) async throws -> String
    func exportGeneratedContent(_ content: String, filename: String) async throws -> URL
}

final class AIService: AIServiceProtocol, @unchecked Sendable {
    private let client: APIClientProtocol
    private let keychain: KeychainServiceProtocol

    init(client: APIClientProtocol, keychain: KeychainServiceProtocol) {
        self.client = client
        self.keychain = keychain
    }

    func generateCoverLetter(request: AICoverLetterRequest) async throws -> String {
        let prompt = """
        Generate a professional cover letter in \(request.language) for:
        Role: \(request.job.title) at \(request.job.company)
        Candidate: \(request.profile.fullName), \(request.profile.headline)
        Skills: \(request.profile.skills.joined(separator: ", "))
        Tone: \(request.tone.rawValue)
        Optimize for ATS and remote international hiring.
        """
        return try await complete(prompt: prompt)
    }

    func startInterview(job: Job, profile: UserProfile) async throws -> AIInterviewSession {
        let questions = [
            "Tell me about yourself and why you're interested in this remote role.",
            "Describe a challenging project relevant to \(job.title).",
            "How do you manage async communication across time zones?",
            "What are your salary expectations for international remote work?",
            "Why should \(job.company) hire someone from \(profile.location)?"
        ].map { AIInterviewQuestion(id: UUID(), question: $0) }

        return AIInterviewSession(
            id: UUID(),
            jobTitle: job.title,
            company: job.company,
            questions: questions,
            startedAt: .now
        )
    }

    func submitInterviewAnswer(sessionId: UUID, questionId: UUID, answer: String) async throws -> String {
        let prompt = "Evaluate this interview answer and provide constructive feedback with a score 1-10:\n\(answer)"
        return try await complete(prompt: prompt)
    }

    func optimizeForATS(cvText: String, job: Job) async throws -> ATSOptimizationResult {
        let prompt = """
        Analyze this CV against the job \(job.title). Return matched keywords, missing keywords, and suggestions.
        CV: \(cvText.prefix(3000))
        Job description: \(job.description.prefix(2000))
        """
        let response = try await complete(prompt: prompt)
        return ATSOptimizationResult(
            score: 75,
            matchedKeywords: job.tags.prefix(5).map { $0 },
            missingKeywords: [],
            suggestions: [response],
            optimizedSummary: response
        )
    }

    func suggestAnswer(question: String, job: Job, profile: UserProfile) async throws -> String {
        let prompt = """
        Suggest a concise professional answer for: \(question)
        Context: applying to \(job.title) at \(job.company)
        Profile: \(profile.headline), skills: \(profile.skills.joined(separator: ", "))
        """
        return try await complete(prompt: prompt)
    }

    func exportGeneratedContent(_ content: String, filename: String) async throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(filename).txt")
        try content.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    private func complete(prompt: String) async throws -> String {
        guard let apiKey = try keychain.read(key: .aiAPIKey), !apiKey.isEmpty else {
            return String(localized: "ai.configureAPIKey")
        }
        // Placeholder: integrate OpenAI-compatible endpoint via backend proxy (recommended for App Store)
        _ = apiKey
        return String(localized: "ai.responsePlaceholder") + "\n\n" + prompt.prefix(200)
    }
}