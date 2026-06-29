import SwiftUI

struct PortfolioEditorView: View {
    @Binding var profile: UserProfile
    var onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section(String(localized: "portfolio.links")) {
                urlField(
                    title: String(localized: "portfolio.website"),
                    icon: "globe",
                    binding: urlBinding(\.websiteURL)
                )
                urlField(
                    title: String(localized: "portfolio.github"),
                    icon: "chevron.left.forwardslash.chevron.right",
                    binding: urlBinding(\.githubURL)
                )
                urlField(
                    title: String(localized: "portfolio.gitlab"),
                    icon: "chevron.left.forwardslash.chevron.right",
                    binding: urlBinding(\.gitlabURL)
                )
                urlField(
                    title: String(localized: "portfolio.linkedin"),
                    icon: "link",
                    binding: urlBinding(\.linkedInURL)
                )
                urlField(
                    title: String(localized: "portfolio.behance"),
                    icon: "paintbrush.fill",
                    binding: urlBinding(\.behanceURL)
                )
                urlField(
                    title: String(localized: "portfolio.youtube"),
                    icon: "play.rectangle.fill",
                    binding: urlBinding(\.youtubeURL)
                )
                urlField(
                    title: String(localized: "portfolio.personal"),
                    icon: "folder.fill",
                    binding: urlBinding(\.portfolioURL)
                )
            }

            Section(String(localized: "portfolio.custom")) {
                ForEach($profile.customLinks) { $link in
                    VStack(alignment: .leading, spacing: 8) {
                        TextField(String(localized: "portfolio.custom.title"), text: $link.title)
                        TextField(String(localized: "portfolio.custom.url"), text: $link.urlString)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.URL)
                            .autocorrectionDisabled()
                    }
                }
                .onDelete { indexSet in
                    profile.customLinks.remove(atOffsets: indexSet)
                }

                Button {
                    profile.customLinks.append(PortfolioLink())
                } label: {
                    Label(String(localized: "portfolio.addLink"), systemImage: "plus.circle.fill")
                }
            }

            Section {
                PrimaryButton(title: String(localized: "save"), action: {
                    onSave()
                    dismiss()
                })
            }
        }
        .navigationTitle(String(localized: "profile.portfolio"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(String(localized: "cancel")) { dismiss() }
            }
        }
    }

    private func urlField(title: String, icon: String, binding: Binding<String>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(ChambeaTheme.Colors.primary)
                .frame(width: 24)
            TextField(title, text: binding)
                .textInputAutocapitalization(.never)
                .keyboardType(.URL)
                .autocorrectionDisabled()
        }
    }

    private func urlBinding(_ keyPath: WritableKeyPath<UserProfile, URL?>) -> Binding<String> {
        Binding(
            get: { profile[keyPath: keyPath]?.absoluteString ?? "" },
            set: { profile[keyPath: keyPath] = Self.normalizedURL(from: $0) }
        )
    }

    private static func normalizedURL(from text: String) -> URL? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        if let url = URL(string: trimmed), url.scheme != nil { return url }
        return URL(string: "https://\(trimmed)")
    }
}