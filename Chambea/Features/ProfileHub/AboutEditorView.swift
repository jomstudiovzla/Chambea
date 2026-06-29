import SwiftUI

struct AboutEditorView: View {
    @Binding var profile: UserProfile
    var onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section(String(localized: "profile.about.short")) {
                TextField(String(localized: "profile.about.short.es"), text: $profile.aboutShortES, axis: .vertical)
                    .lineLimit(3...6)
                TextField(String(localized: "profile.about.short.en"), text: $profile.aboutShortEN, axis: .vertical)
                    .lineLimit(3...6)
            }
            Section(String(localized: "profile.about.long")) {
                TextEditor(text: $profile.aboutLongES)
                    .frame(minHeight: 100)
                TextEditor(text: $profile.aboutLongEN)
                    .frame(minHeight: 100)
            }
            Section {
                PrimaryButton(title: String(localized: "save"), action: {
                    onSave()
                    dismiss()
                })
            }
        }
        .navigationTitle(String(localized: "profile.section.about"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(String(localized: "cancel")) { dismiss() }
            }
        }
    }
}