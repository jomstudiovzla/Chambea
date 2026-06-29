import SwiftUI

struct ATSOptimizationView: View {
    @State private var result: ATSOptimizationResult?
    @State private var isLoading = false

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else if let result {
                VStack(alignment: .leading, spacing: 12) {
                    Text(String(localized: "ai.ats.score \(result.score)"))
                        .font(ChambeaTheme.Typography.title)
                    if !result.matchedKeywords.isEmpty {
                        Text(String(localized: "ai.ats.matched")).font(.headline)
                        FlowLayout { ForEach(result.matchedKeywords, id: \.self) { ChambeaChip(text: $0) } }
                    }
                    if !result.suggestions.isEmpty {
                        Text(String(localized: "ai.ats.suggestions")).font(.headline)
                        ForEach(result.suggestions, id: \.self) { Text("• \($0)") }
                    }
                }
                .padding()
            } else {
                EmptyStateView(
                    icon: "doc.text.magnifyingglass",
                    title: String(localized: "ai.ats"),
                    message: String(localized: "ai.ats.hint"),
                    actionTitle: String(localized: "analyze")
                ) { Task { await analyze() } }
            }
        }
        .navigationTitle(String(localized: "ai.ats"))
    }

    private func analyze() async {
        isLoading = true
        defer { isLoading = false }
        let useCase = AIAssistantUseCase(aiService: DIContainer.shared.aiService)
        let docs = (try? await DIContainer.shared.documentRepository.getDocuments()) ?? []
        guard let cv = docs.first(where: { $0.type == .cv }) else { return }
        let text = (try? String(contentsOf: cv.localURL)) ?? ""
        let job = Job(
            id: "ats", title: "Remote Role", company: "Target", description: "Swift iOS remote",
            location: "Remote", country: nil, isRemote: true, remoteType: .fullyRemote,
            salaryMin: nil, salaryMax: nil, salaryCurrency: nil, seniority: .mid,
            industry: nil, contractType: .fullTime, languages: ["en"], tags: ["Swift", "iOS"],
            source: .manual, sourceURL: URL(string: "https://chambea.app")!,
            applyURL: nil, publishedAt: .now, logoURL: nil
        )
        result = try? await useCase.optimizeForATS(cvText: text, job: job)
    }
}