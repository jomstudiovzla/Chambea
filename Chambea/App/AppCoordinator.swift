import SwiftUI

@MainActor
final class AppCoordinator: ObservableObject {
    @Published var selectedTab: MainTab = .search
    @Published var preferredColorScheme: ColorScheme?
    @Published var isOnboardingComplete: Bool

    private let userDefaults = UserDefaults.standard

    init() {
        isOnboardingComplete = userDefaults.bool(forKey: "onboardingComplete")
    }

    var rootView: some View {
        Group {
            if isOnboardingComplete {
                MainTabView()
            } else {
                OnboardingView(onComplete: completeOnboarding)
            }
        }
    }

    func completeOnboarding() {
        isOnboardingComplete = true
        userDefaults.set(true, forKey: "onboardingComplete")
    }

    func navigate(to tab: MainTab) {
        selectedTab = tab
    }
}

enum MainTab: String, CaseIterable, Identifiable {
    case search
    case saved
    case profile
    case ai
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .search: return String(localized: "tab.search")
        case .saved: return String(localized: "tab.saved")
        case .profile: return String(localized: "tab.profile")
        case .ai: return String(localized: "tab.ai")
        case .settings: return String(localized: "tab.settings")
        }
    }

    var systemImage: String {
        switch self {
        case .search: return "magnifyingglass"
        case .saved: return "bookmark.fill"
        case .profile: return "person.crop.circle.fill"
        case .ai: return "sparkles"
        case .settings: return "gearshape.fill"
        }
    }
}