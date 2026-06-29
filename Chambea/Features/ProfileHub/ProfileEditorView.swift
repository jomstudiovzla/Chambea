import SwiftUI

struct ProfileEditorView: View {
    @Binding var profile: UserProfile
    var onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section(String(localized: "profile.basic")) {
                TextField(String(localized: "profile.name"), text: $profile.fullName)
                    .textContentType(.name)
                    .autocorrectionDisabled()
                TextField(String(localized: "profile.headline"), text: $profile.headline, prompt: Text(String(localized: "profile.headline.placeholder")))
                TextField(String(localized: "profile.location"), text: $profile.location)
            }
            Section(String(localized: "profile.bio")) {
                TextEditor(text: $profile.bio)
                    .frame(minHeight: 120)
                    .overlay(alignment: .topLeading) {
                        if profile.bio.isEmpty {
                            Text(String(localized: "profile.bio.placeholder"))
                                .foregroundStyle(.tertiary)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                                .allowsHitTesting(false)
                        }
                    }
            }
            Section(String(localized: "profile.skills")) {
                TextField(String(localized: "profile.skills.placeholder"), text: skillsBinding)
            }
            Section {
                PrimaryButton(title: String(localized: "save"), action: {
                    onSave()
                    dismiss()
                })
            }
        }
        .navigationTitle(String(localized: "profile.edit"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(String(localized: "cancel")) { dismiss() }
            }
        }
    }

    private var skillsBinding: Binding<String> {
        Binding(
            get: { profile.skills.joined(separator: ", ") },
            set: { profile.skills = $0.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty } }
        )
    }
}