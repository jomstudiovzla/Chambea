import SwiftUI

struct SocialContactEditorView: View {
    @Binding var profile: UserProfile
    var onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    private let defaultPlatforms = ["LinkedIn", "X", "Instagram", "TikTok", "Web", "Email", "WhatsApp"]

    var body: some View {
        Form {
            Section(String(localized: "profile.social.title")) {
                ForEach($profile.socialLinks) { $link in
                    VStack(alignment: .leading, spacing: 8) {
                        TextField(String(localized: "portfolio.custom.title"), text: $link.platform)
                        TextField(String(localized: "portfolio.custom.url"), text: $link.urlString)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.URL)
                            .autocorrectionDisabled()
                        Picker(String(localized: "profile.visibility.title"), selection: $link.visibility) {
                            ForEach(ContactVisibility.allCases, id: \.self) { visibility in
                                Text(visibility.displayName).tag(visibility)
                            }
                        }
                    }
                }
                .onDelete { profile.socialLinks.remove(atOffsets: $0) }

                Menu(String(localized: "profile.social.add")) {
                    ForEach(defaultPlatforms, id: \.self) { platform in
                        Button(platform) {
                            profile.socialLinks.append(SocialLink(platform: platform))
                        }
                    }
                    Button(String(localized: "profile.social.add.custom")) {
                        profile.socialLinks.append(SocialLink(platform: ""))
                    }
                }
            }

            Section(String(localized: "profile.social.preview")) {
                ForEach(visibleLinks) { link in
                    Label(link.platform, systemImage: "link")
                    if let url = link.url {
                        Text(url.absoluteString)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                if visibleLinks.isEmpty {
                    Text(String(localized: "profile.social.preview.empty"))
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                PrimaryButton(title: String(localized: "save"), action: {
                    onSave()
                    dismiss()
                })
            }
        }
        .navigationTitle(String(localized: "profile.section.social"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(String(localized: "cancel")) { dismiss() }
            }
        }
        .onAppear { ensureDefaultLinks() }
    }

    private var visibleLinks: [SocialLink] {
        profile.socialLinks.filter { !$0.urlString.isEmpty && $0.visibility != .private }
    }

    private func ensureDefaultLinks() {
        guard profile.socialLinks.isEmpty else { return }
        profile.socialLinks = defaultPlatforms.map { SocialLink(platform: $0) }
    }
}