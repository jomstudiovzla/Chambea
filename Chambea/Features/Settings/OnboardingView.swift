import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void
    @State private var page = 0

    private let pages: [(icon: String, title: String, message: String)] = [
        ("globe.americas.fill", "onboarding.page1.title", "onboarding.page1.message"),
        ("briefcase.fill", "onboarding.page2.title", "onboarding.page2.message"),
        ("sparkles", "onboarding.page3.title", "onboarding.page3.message")
    ]

    var body: some View {
        VStack(spacing: 32) {
            TabView(selection: $page) {
                ForEach(0..<pages.count, id: \.self) { index in
                    VStack(spacing: 20) {
                        Image(systemName: pages[index].icon)
                            .font(.system(size: 64))
                            .foregroundStyle(ChambeaTheme.Colors.primary)
                        Text(String(localized: String.LocalizationValue(pages[index].title)))
                            .font(ChambeaTheme.Typography.title)
                        Text(String(localized: String.LocalizationValue(pages[index].message)))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page)
            .frame(height: 400)

            PrimaryButton(title: page == pages.count - 1 ? String(localized: "onboarding.start") : String(localized: "next")) {
                if page < pages.count - 1 {
                    withAnimation { page += 1 }
                } else {
                    Task {
                        _ = try? await DIContainer.shared.notificationService.requestAuthorization()
                    }
                    onComplete()
                }
            }
            .padding(.horizontal)
        }
        .padding()
    }
}