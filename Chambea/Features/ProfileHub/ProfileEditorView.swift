import SwiftUI

struct ProfileEditorView: View {
    @Binding var profile: UserProfile
    var onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    private let timeZones = [
        "America/Caracas",
        "America/Mexico_City",
        "America/Bogota",
        "America/Santiago",
        "America/Argentina/Buenos_Aires",
        "Europe/Madrid"
    ]

    var body: some View {
        Form {
            Section(String(localized: "profile.basic")) {
                TextField(String(localized: "profile.name"), text: $profile.fullName)
                    .textContentType(.name)
                    .autocorrectionDisabled()
                TextField(String(localized: "profile.headline.es"), text: $profile.headlineES, prompt: Text(String(localized: "profile.headline.placeholder")))
                TextField(String(localized: "profile.headline.en"), text: $profile.headlineEN)
                TextField(String(localized: "profile.location"), text: $profile.location)
                Picker(String(localized: "profile.timezone"), selection: $profile.timeZoneIdentifier) {
                    ForEach(timeZones, id: \.self) { zone in
                        Text(zone).tag(zone)
                    }
                }
            }

            Section(String(localized: "profile.availability.title")) {
                ForEach(WorkAvailability.allCases, id: \.self) { option in
                    Toggle(option.displayName, isOn: availabilityBinding(option))
                }
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

            Section {
                PrimaryButton(title: String(localized: "save"), action: {
                    profile.headline = profile.headlineES.isEmpty ? profile.headlineEN : profile.headlineES
                    onSave()
                    dismiss()
                })
            }
        }
        .navigationTitle(String(localized: "profile.section.basic"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(String(localized: "cancel")) { dismiss() }
            }
        }
    }

    private func availabilityBinding(_ option: WorkAvailability) -> Binding<Bool> {
        Binding(
            get: { profile.availability.contains(option) },
            set: { isOn in
                if isOn {
                    profile.availability.append(option)
                } else {
                    profile.availability.removeAll { $0 == option }
                }
            }
        )
    }
}