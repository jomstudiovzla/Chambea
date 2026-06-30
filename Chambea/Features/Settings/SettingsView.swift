import SwiftUI

struct SettingsView: View {
    @AppStorage("appLanguage") private var appLanguage = "es"
    @AppStorage("colorScheme") private var colorScheme = "system"
    @State private var notificationsEnabled = false
    @State private var enabledSources: Set<JobSource> = Set(JobSource.allCases)
    @State private var aiAPIKey = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(String(localized: "settings.language")) {
                    Picker(String(localized: "settings.language"), selection: $appLanguage) {
                        Text("Español").tag("es")
                        Text("English").tag("en")
                        Text("Português").tag("pt")
                    }
                }
                Section(String(localized: "settings.appearance")) {
                    Picker(String(localized: "settings.theme"), selection: $colorScheme) {
                        Text(String(localized: "settings.theme.system")).tag("system")
                        Text(String(localized: "settings.theme.light")).tag("light")
                        Text(String(localized: "settings.theme.dark")).tag("dark")
                    }
                }
                Section(String(localized: "settings.notifications")) {
                    Toggle(String(localized: "settings.notifications.enable"), isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { _, enabled in
                            if enabled { Task { _ = try? await DIContainer.shared.notificationService.requestAuthorization() } }
                        }
                    NavigationLink(String(localized: "alerts.title")) { AlertsView() }
                }
                Section(String(localized: "settings.sources")) {
                    ForEach(JobSource.allCases, id: \.self) { source in
                        Toggle(source.displayName, isOn: binding(for: source))
                    }
                }
                Section(String(localized: "settings.ai")) {
                    SecureField(String(localized: "settings.ai.apiKey"), text: $aiAPIKey)
                    Button(String(localized: "save")) { saveAPIKey() }
                }
                Section(String(localized: "settings.privacy")) {
                    NavigationLink(String(localized: "settings.privacy.policy")) { PrivacyPolicyView() }
                    NavigationLink(String(localized: "settings.privacy.data")) { DataManagementView() }
                }
                Section(String(localized: "settings.install.section")) {
                    InstallOnDeviceButton(style: .prominent)
                        .listRowBackground(Color.clear)
                }
                Section(String(localized: "settings.about")) {
                    LabeledContent(String(localized: "settings.version"), value: "1.0.0")
                    Link(destination: URL(string: QRCodeGenerator.repositoryURL)!) {
                        Label(String(localized: "settings.install.repository"), systemImage: "link")
                    }
                }
            }
            .navigationTitle(String(localized: "settings.title"))
        }
    }

    private func binding(for source: JobSource) -> Binding<Bool> {
        Binding(
            get: { enabledSources.contains(source) },
            set: { isOn in
                if isOn { enabledSources.insert(source) } else { enabledSources.remove(source) }
            }
        )
    }

    private func saveAPIKey() {
        try? DIContainer.shared.keychainService.save(aiAPIKey, for: .aiAPIKey)
    }
}