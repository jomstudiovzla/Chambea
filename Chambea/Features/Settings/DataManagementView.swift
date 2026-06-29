import SwiftUI

struct DataManagementView: View {
    @State private var showDeleteConfirmation = false

    var body: some View {
        List {
            Section(String(localized: "privacy.data.stored")) {
                Text(String(localized: "privacy.data.stored.description"))
            }
            Section(String(localized: "privacy.data.export")) {
                Button(String(localized: "privacy.data.export.action")) { }
            }
            Section(String(localized: "privacy.data.delete")) {
                Button(String(localized: "privacy.data.delete.action"), role: .destructive) {
                    showDeleteConfirmation = true
                }
            }
        }
        .navigationTitle(String(localized: "settings.privacy.data"))
        .confirmationDialog(
            String(localized: "privacy.data.delete.confirm"),
            isPresented: $showDeleteConfirmation
        ) {
            Button(String(localized: "delete"), role: .destructive) { }
            Button(String(localized: "cancel"), role: .cancel) { }
        }
    }
}