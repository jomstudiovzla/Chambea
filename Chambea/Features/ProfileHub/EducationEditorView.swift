import SwiftUI

struct EducationEditorView: View {
    @Binding var profile: UserProfile
    var onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section(String(localized: "profile.education.title")) {
                ForEach($profile.education) { $entry in
                    VStack(alignment: .leading, spacing: 8) {
                        TextField(String(localized: "profile.education.institution"), text: $entry.institution)
                        TextField(String(localized: "profile.education.degree"), text: $entry.degree)
                        TextField(String(localized: "profile.education.country"), text: $entry.country)
                        DatePicker(String(localized: "profile.experience.start"), selection: $entry.startDate, displayedComponents: .date)
                    }
                }
                .onDelete { profile.education.remove(atOffsets: $0) }

                Button(String(localized: "profile.education.add")) {
                    profile.education.append(EducationEntry())
                }
            }

            Section(String(localized: "profile.certifications.title")) {
                ForEach($profile.certifications) { $cert in
                    VStack(alignment: .leading, spacing: 8) {
                        TextField(String(localized: "profile.certifications.name"), text: $cert.name)
                        TextField(String(localized: "profile.certifications.issuer"), text: $cert.issuer)
                        TextField(String(localized: "profile.certifications.url"), text: certificationURLBinding(for: $cert))
                            .textInputAutocapitalization(.never)
                            .keyboardType(.URL)
                            .autocorrectionDisabled()
                    }
                }
                .onDelete { profile.certifications.remove(atOffsets: $0) }

                Button(String(localized: "profile.certifications.add")) {
                    profile.certifications.append(CertificationEntry())
                }
            }

            Section {
                PrimaryButton(title: String(localized: "save"), action: {
                    onSave()
                    dismiss()
                })
            }
        }
        .navigationTitle(String(localized: "profile.section.education"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(String(localized: "cancel")) { dismiss() }
            }
        }
    }

    private func certificationURLBinding(for cert: Binding<CertificationEntry>) -> Binding<String> {
        Binding(
            get: { cert.wrappedValue.verificationURL?.absoluteString ?? "" },
            set: { cert.wrappedValue.verificationURL = $0.isEmpty ? nil : URL(string: $0) }
        )
    }
}