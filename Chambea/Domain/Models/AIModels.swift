import Foundation

struct AIInterviewSession: Identifiable, Sendable {
    let id: UUID
    let jobTitle: String
    let company: String
    var questions: [AIInterviewQuestion]
    var startedAt: Date
    var completedAt: Date?
}

struct AIInterviewQuestion: Identifiable, Sendable {
    let id: UUID
    let question: String
    var userAnswer: String?
    var aiFeedback: String?
    var score: Int?
}

struct AICoverLetterRequest: Sendable {
    let job: Job
    let profile: UserProfile
    let tone: AITone
    let language: String
}

struct ATSOptimizationResult: Sendable {
    let score: Int
    let matchedKeywords: [String]
    let missingKeywords: [String]
    let suggestions: [String]
    let optimizedSummary: String
}

enum AITone: String, CaseIterable, Sendable {
    case professional
    case friendly
    case concise

    var displayName: String {
        rawValue.capitalized
    }
}

enum AIFeature: String, CaseIterable, Sendable {
    case interview
    case coverLetter
    case atsOptimization
    case answerHelper
    case profileOptimization

    var displayName: String {
        switch self {
        case .interview: return String(localized: "ai.interview")
        case .coverLetter: return String(localized: "ai.coverLetter")
        case .atsOptimization: return String(localized: "ai.ats")
        case .answerHelper: return String(localized: "ai.answerHelper")
        case .profileOptimization: return String(localized: "ai.profile")
        }
    }
}