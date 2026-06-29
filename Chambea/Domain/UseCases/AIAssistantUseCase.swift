import Foundation

struct AIAssistantUseCase: Sendable {
    let aiService: AIServiceProtocol

    func generateCoverLetter(request: AICoverLetterRequest) async throws -> String {
        try await aiService.generateCoverLetter(request: request)
    }

    func startInterview(job: Job, profile: UserProfile) async throws -> AIInterviewSession {
        try await aiService.startInterview(job: job, profile: profile)
    }

    func optimizeForATS(cvText: String, job: Job) async throws -> ATSOptimizationResult {
        try await aiService.optimizeForATS(cvText: cvText, job: job)
    }

    func suggestAnswer(question: String, job: Job, profile: UserProfile) async throws -> String {
        try await aiService.suggestAnswer(question: question, job: job, profile: profile)
    }
}