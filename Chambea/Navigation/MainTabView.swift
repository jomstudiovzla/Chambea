import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var coordinator: AppCoordinator

    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            SearchView()
                .tabItem { Label(MainTab.search.title, systemImage: MainTab.search.systemImage) }
                .tag(MainTab.search)

            SavedJobsView()
                .tabItem { Label(MainTab.saved.title, systemImage: MainTab.saved.systemImage) }
                .tag(MainTab.saved)

            ProfileHubView()
                .tabItem { Label(MainTab.profile.title, systemImage: MainTab.profile.systemImage) }
                .tag(MainTab.profile)

            AIHubView()
                .tabItem { Label(MainTab.ai.title, systemImage: MainTab.ai.systemImage) }
                .tag(MainTab.ai)

            SettingsView()
                .tabItem { Label(MainTab.settings.title, systemImage: MainTab.settings.systemImage) }
                .tag(MainTab.settings)
        }
        .tint(ChambeaTheme.Colors.primary)
    }
}