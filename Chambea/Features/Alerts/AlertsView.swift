import SwiftUI

struct AlertsView: View {
    @State private var alerts: [JobAlert] = []
    @State private var showCreate = false

    var body: some View {
        Group {
            if alerts.isEmpty {
                EmptyStateView(
                    icon: "bell.badge",
                    title: String(localized: "alerts.empty.title"),
                    message: String(localized: "alerts.empty.message"),
                    actionTitle: String(localized: "alerts.create")
                ) { showCreate = true }
            } else {
                List(alerts) { alert in
                    VStack(alignment: .leading) {
                        Text(alert.name).font(.headline)
                        Text(alert.frequency.displayName).font(.caption).foregroundStyle(.secondary)
                        Toggle("", isOn: binding(for: alert))
                    }
                }
            }
        }
        .navigationTitle(String(localized: "alerts.title"))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showCreate = true }) { Image(systemName: "plus") }
            }
        }
        .sheet(isPresented: $showCreate) {
            CreateAlertView { alert in
                Task {
                    try? await DIContainer.shared.alertRepository.createAlert(alert)
                    await load()
                }
            }
        }
        .task { await load() }
    }

    private func load() async {
        alerts = (try? await DIContainer.shared.alertRepository.getAlerts()) ?? []
    }

    private func binding(for alert: JobAlert) -> Binding<Bool> {
        Binding(
            get: { alert.isEnabled },
            set: { newValue in
                var updated = alert
                updated.isEnabled = newValue
                Task { try? await DIContainer.shared.alertRepository.updateAlert(updated) }
            }
        )
    }
}

struct CreateAlertView: View {
    let onCreate: (JobAlert) -> Void
    @State private var name = ""
    @State private var frequency: AlertFrequency = .daily
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                TextField(String(localized: "alerts.name"), text: $name)
                Picker(String(localized: "alerts.frequency"), selection: $frequency) {
                    ForEach(AlertFrequency.allCases, id: \.self) { f in
                        Text(f.displayName).tag(f)
                    }
                }
            }
            .navigationTitle(String(localized: "alerts.create"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "save")) {
                        onCreate(JobAlert(
                            id: UUID(), name: name, filter: JobFilter(),
                            isEnabled: true, frequency: frequency,
                            lastTriggeredAt: nil, createdAt: .now
                        ))
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}