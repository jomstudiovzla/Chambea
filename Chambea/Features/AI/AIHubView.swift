import SwiftUI

struct AIHubView: View {
    var body: some View {
        NavigationStack {
            List(AIFeature.allCases, id: \.self) { feature in
                NavigationLink {
                    destination(for: feature)
                } label: {
                    Label(feature.displayName, systemImage: icon(for: feature))
                }
            }
            .navigationTitle(String(localized: "ai.title"))
        }
    }

    @ViewBuilder
    private func destination(for feature: AIFeature) -> some View {
        switch feature {
        case .interview:
            Text(String(localized: "ai.interview.selectJob"))
        case .coverLetter:
            AICoverLetterView()
        case .atsOptimization:
            ATSOptimizationView()
        case .answerHelper:
            AIAnswerHelperView()
        case .profileOptimization:
            ProfileHubView()
        }
    }

    private func icon(for feature: AIFeature) -> String {
        switch feature {
        case .interview: return "person.wave.2.fill"
        case .coverLetter: return "envelope.fill"
        case .atsOptimization: return "doc.text.magnifyingglass"
        case .answerHelper: return "text.bubble.fill"
        case .profileOptimization: return "person.crop.circle.badge.checkmark"
        }
    }
}