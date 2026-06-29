import SwiftUI

struct AIAnswerHelperView: View {
    @State private var question = ""
    @State private var answer = ""
    @State private var isLoading = false

    var body: some View {
        Form {
            Section(String(localized: "ai.question")) {
                TextField(String(localized: "ai.question.placeholder"), text: $question, axis: .vertical)
            }
            Section(String(localized: "ai.suggestedAnswer")) {
                if isLoading {
                    ProgressView()
                } else {
                    Text(answer.isEmpty ? String(localized: "ai.answer.empty") : answer)
                }
            }
            Section {
                PrimaryButton(title: String(localized: "generate"), isLoading: isLoading) {
                    Task { await generate() }
                }
            }
        }
        .navigationTitle(String(localized: "ai.answerHelper"))
    }

    private func generate() async {
        isLoading = true
        defer { isLoading = false }
        let useCase = AIAssistantUseCase(aiService: DIContainer.shared.aiService)
        let profile = try? await DIContainer.shared.profileRepository.getProfile()
        guard let profile else { return }
        let job = Job(
            id: "helper", title: "Remote", company: "Co", description: "",
            location: "Remote", country: nil, isRemote: true, remoteType: .fullyRemote,
            salaryMin: nil, salaryMax: nil, salaryCurrency: nil, seniority: .mid,
            industry: nil, contractType: .fullTime, languages: ["en"], tags: [],
            source: .manual, sourceURL: URL(string: "https://chambea.app")!,
            applyURL: nil, publishedAt: .now, logoURL: nil
        )
        answer = (try? await useCase.suggestAnswer(question: question, job: job, profile: profile)) ?? ""
    }
}