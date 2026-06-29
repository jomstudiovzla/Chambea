import SwiftUI

struct ExperienceEditorView: View {
    @Binding var profile: UserProfile
    var onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            ForEach($profile.experiences) { $entry in
                Section {
                    TextField(String(localized: "profile.experience.title"), text: $entry.title)
                    TextField(String(localized: "profile.experience.company"), text: $entry.company)
                    Toggle(String(localized: "profile.experience.current"), isOn: $entry.isCurrent)
                    Toggle(String(localized: "profile.experience.remote"), isOn: $entry.isRemoteOrInternational)
                    DatePicker(String(localized: "profile.experience.start"), selection: $entry.startDate, displayedComponents: .date)
                    if !entry.isCurrent {
                        DatePicker(String(localized: "profile.experience.end"), selection: Binding(
                            get: { entry.endDate ?? .now },
                            set: { entry.endDate = $0 }
                        ), displayedComponents: .date)
                    }
                    TextField(String(localized: "profile.experience.sectors"), text: sectorsBinding(for: $entry))
                    TextEditor(text: $entry.description)
                        .frame(minHeight: 80)
                    TextEditor(text: $entry.achievements)
                        .frame(minHeight: 60)
                }
            }
            .onDelete { profile.experiences.remove(atOffsets: $0) }
            .onMove { profile.experiences.move(fromOffsets: $0, toOffset: $1) }

            Section {
                Button(String(localized: "profile.experience.add")) {
                    profile.experiences.append(ExperienceEntry())
                }
            }

            Section {
                PrimaryButton(title: String(localized: "save"), action: {
                    onSave()
                    dismiss()
                })
            }
        }
        .navigationTitle(String(localized: "profile.section.experience"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(String(localized: "cancel")) { dismiss() }
            }
            ToolbarItem(placement: .primaryAction) {
                EditButton()
            }
        }
    }

    private func sectorsBinding(for entry: Binding<ExperienceEntry>) -> Binding<String> {
        Binding(
            get: { entry.wrappedValue.sectors.joined(separator: ", ") },
            set: { entry.wrappedValue.sectors = $0.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty } }
        )
    }
}