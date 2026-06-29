import SwiftUI

struct SkillsEditorView: View {
    @Binding var profile: UserProfile
    var onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section(String(localized: "profile.skills")) {
                TextField(String(localized: "profile.skills.placeholder"), text: skillsBinding)
            }

            Section(String(localized: "profile.languages.title")) {
                ForEach($profile.languageSkills) { $skill in
                    HStack {
                        TextField(String(localized: "profile.languages.code"), text: $skill.language)
                            .frame(width: 60)
                        Picker(String(localized: "profile.languages.level"), selection: $skill.level) {
                            ForEach(LanguageLevel.allCases, id: \.self) { level in
                                Text(level.displayName).tag(level)
                            }
                        }
                    }
                }
                .onDelete { profile.languageSkills.remove(atOffsets: $0) }

                Button(String(localized: "profile.languages.add")) {
                    profile.languageSkills.append(LanguageSkill())
                }
            }

            Section {
                PrimaryButton(title: String(localized: "save"), action: {
                    onSave()
                    dismiss()
                })
            }
        }
        .navigationTitle(String(localized: "profile.section.skills"))
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