import SwiftUI
import SwiftData

@main
struct ChambeaApp: App {
    @StateObject private var appCoordinator = AppCoordinator()
    private let container = DIContainer.shared

    var body: some Scene {
        WindowGroup {
            appCoordinator.rootView
                .environmentObject(appCoordinator)
                .modelContainer(container.modelContainer)
                .preferredColorScheme(appCoordinator.preferredColorScheme)
        }
    }
}