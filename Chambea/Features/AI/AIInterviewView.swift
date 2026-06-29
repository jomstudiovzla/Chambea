import SwiftUI

struct AIInterviewView: View {
    let job: Job
    @State private var session: AIInterviewSession?
    @State private var currentIndex = 0
    @State private var answer = ""
    @State private var feedback = ""

    private let useCase = AIAssistantUseCase(aiService: DIContainer.shared.aiService)

    var body: some View {
        VStack(spacing: 16) {
            if let session {
                ProgressView(value: Double(currentIndex + 1), total: Double(session.questions.count))
                Text(session.questions[currentIndex].question)
                    .font(ChambeaTheme.Typography.headline)
                TextEditor(text: $answer)
                    .frame(minHeight: 120)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(.secondary.opacity(0.3)))
                if !feedback.isEmpty {
                    Text(feedback).font(.caption).foregroundStyle(.secondary)
                }
                PrimaryButton(title: String(localized: "ai.submitAnswer"), isLoading: false) {
                    Task { await submitAnswer(session: session) }
                }
            } else {
                EmptyStateView(
                    icon: "sparkles",
                    title: String(localized: "ai.interview"),
                    message: String(localized: "ai.interview.start"),
                    actionTitle: String(localized: "start")
                ) { Task { await start() } }
            }
        }
        .padding()
        .navigationTitle(String(localized: "ai.interview"))
    }

    private func start() async {
        let profile = (try? await DIContainer.shared.profileRepository.getProfile()) ?? .empty
        session = try? await useCase.startInterview(job: job, profile: profile)
    }

    private func submitAnswer(session: AIInterviewSession) async {
        let question = session.questions[currentIndex]
        feedback = (try? await DIContainer.shared.aiService.submitInterviewAnswer(
            sessionId: session.id, questionId: question.id, answer: answer
        )) ?? ""
        answer = ""
        if currentIndex < session.questions.count - 1 {
            currentIndex += 1
        }
    }
}