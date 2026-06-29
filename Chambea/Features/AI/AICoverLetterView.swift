import SwiftUI

struct AICoverLetterView: View {
    @State private var result = ""
    @State private var isLoading = false
    @State private var tone: AITone = .professional

    var body: some View {
        VStack(spacing: 16) {
            Picker(String(localized: "ai.tone"), selection: $tone) {
                ForEach(AITone.allCases, id: \.self) { t in
                    Text(t.displayName).tag(t)
                }
            }
            .pickerStyle(.segmented)

            if isLoading {
                ProgressView()
            } else if result.isEmpty {
                EmptyStateView(
                    icon: "envelope",
                    title: String(localized: "ai.coverLetter"),
                    message: String(localized: "ai.coverLetter.hint"),
                    actionTitle: String(localized: "generate")
                ) { Task { await generate() } }
            } else {
                ScrollView {
                    Text(result).font(ChambeaTheme.Typography.body)
                }
                HStack {
                    ShareLink(item: result) { Label(String(localized: "share"), systemImage: "square.and.arrow.up") }
                    Button(String(localized: "documents.export")) { Task { await export() } }
                }
            }
        }
        .padding()
        .navigationTitle(String(localized: "ai.coverLetter"))
    }

    private func generate() async {
        isLoading = true
        defer { isLoading = false }
        let useCase = AIAssistantUseCase(aiService: DIContainer.shared.aiService)
        let profile = try? await DIContainer.shared.profileRepository.getProfile()
        let job = Job(
            id: "demo", title: "Remote Developer", company: "Demo Co", description: "",
            location: "Remote", country: nil, isRemote: true, remoteType: .fullyRemote,
            salaryMin: nil, salaryMax: nil, salaryCurrency: nil, seniority: .mid,
            industry: nil, contractType: .fullTime, languages: ["en"], tags: [],
            source: .manual, sourceURL: URL(string: "https://chambea.app")!,
            applyURL: nil, publishedAt: .now, logoURL: nil
        )
        guard let profile else { return }
        result = (try? await useCase.generateCoverLetter(request: AICoverLetterRequest(
            job: job, profile: profile, tone: tone, language: "es"
        ))) ?? ""
    }

    private func export() async {
        _ = try? await DIContainer.shared.aiService.exportGeneratedContent(result, filename: "cover-letter")
    }
}