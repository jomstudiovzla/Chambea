import SwiftUI
import PhotosUI

struct ProfileHubView: View {
    @State private var profile = UserProfile.empty
    @State private var selectedPhoto: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    profileHeader
                    completionCard
                    sectionGrid
                    hubActions
                }
                .padding()
            }
            .background(ChambeaTheme.Colors.background.ignoresSafeArea())
            .navigationTitle(String(localized: "profile.hub.title"))
            .task { await loadProfile() }
            .onChange(of: selectedPhoto) { _, item in
                Task { await importPhoto(item) }
            }
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 16) {
            ZStack(alignment: .bottomTrailing) {
                ProfileAvatarView(
                    name: displayName,
                    imageURL: profile.profilePhotoURL,
                    size: 120
                )

                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Image(systemName: "camera.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(ChambeaTheme.Colors.primary)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .offset(x: 4, y: 4)
            }

            VStack(spacing: 6) {
                Text(displayName)
                    .font(ChambeaTheme.Typography.title)
                    .multilineTextAlignment(.center)

                let headline = profile.headlineES.isEmpty ? profile.headline : profile.headlineES
                if !headline.isEmpty {
                    Text(headline)
                        .font(ChambeaTheme.Typography.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                if !profile.location.isEmpty {
                    Label(profile.location, systemImage: "mappin.and.ellipse")
                        .font(ChambeaTheme.Typography.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    private var completionCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(String(localized: "profile.hub.completion"))
                    .font(ChambeaTheme.Typography.headline)
                Spacer()
                Text("\(profile.completionPercentage)%")
                    .font(.headline)
                    .foregroundStyle(ChambeaTheme.Colors.primary)
            }
            ProgressView(value: Double(profile.completionPercentage), total: 100)
                .tint(ChambeaTheme.Colors.primary)
        }
        .padding(ChambeaTheme.cardPadding)
        .background(ChambeaTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: ChambeaTheme.cornerRadius))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }

    private var sectionGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "profile.hub.sections"))
                .font(ChambeaTheme.Typography.headline)

            ForEach(ProfileHubSection.allCases) { section in
                sectionRow(section)
            }
        }
    }

    private func sectionRow(_ section: ProfileHubSection) -> some View {
        let status = section.status(for: profile)
        return NavigationLink {
            destination(for: section)
        } label: {
            HStack(spacing: 14) {
                Image(systemName: section.icon)
                    .font(.title3)
                    .foregroundStyle(ChambeaTheme.Colors.primary)
                    .frame(width: 36)

                VStack(alignment: .leading, spacing: 4) {
                    Text(section.title)
                        .font(ChambeaTheme.Typography.headline)
                        .foregroundStyle(ChambeaTheme.Colors.textPrimary)
                    Text(status.displayName)
                        .font(ChambeaTheme.Typography.caption)
                        .foregroundStyle(statusColor(status))
                }

                Spacer()

                statusBadge(status)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(ChambeaTheme.cardPadding)
            .background(ChambeaTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: ChambeaTheme.cornerRadius))
            .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
        }
    }

    @ViewBuilder
    private func destination(for section: ProfileHubSection) -> some View {
        switch section {
        case .basicInfo:
            ProfileEditorView(profile: $profile) { Task { await saveProfile() } }
        case .about:
            AboutEditorView(profile: $profile) { Task { await saveProfile() } }
        case .experience:
            ExperienceEditorView(profile: $profile) { Task { await saveProfile() } }
        case .education:
            EducationEditorView(profile: $profile) { Task { await saveProfile() } }
        case .skills:
            SkillsEditorView(profile: $profile) { Task { await saveProfile() } }
        case .portfolio:
            PortfolioEditorView(profile: $profile) { Task { await saveProfile() } }
        case .socialContact:
            SocialContactEditorView(profile: $profile) { Task { await saveProfile() } }
        case .presentationVideo:
            PresentationVideoView(profile: $profile) { Task { await saveProfile() } }
        }
    }

    private var hubActions: some View {
        VStack(spacing: 12) {
            hubRow(
                icon: "folder.fill",
                title: String(localized: "profile.documents"),
                destination: AnyView(DocumentsView())
            )
        }
    }

    private func hubRow(icon: String, title: String, destination: AnyView) -> some View {
        NavigationLink {
            destination
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(ChambeaTheme.Colors.primary)
                    .frame(width: 36)
                Text(title)
                    .font(ChambeaTheme.Typography.headline)
                    .foregroundStyle(ChambeaTheme.Colors.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(ChambeaTheme.cardPadding)
            .background(ChambeaTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: ChambeaTheme.cornerRadius))
            .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
        }
    }

    @ViewBuilder
    private func statusBadge(_ status: ProfileSectionStatus) -> some View {
        switch status {
        case .complete:
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
        case .partial:
            Image(systemName: "circle.lefthalf.filled")
                .foregroundStyle(.orange)
        case .empty:
            Image(systemName: "circle")
                .foregroundStyle(.tertiary)
        }
    }

    private func statusColor(_ status: ProfileSectionStatus) -> Color {
        switch status {
        case .complete: .green
        case .partial: .orange
        case .empty: .secondary
        }
    }

    private var displayName: String {
        let trimmed = profile.fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? String(localized: "profile.noName") : trimmed
    }

    private func loadProfile() async {
        if let saved = try? await DIContainer.shared.profileRepository.getProfile() {
            profile = saved
        }
    }

    private func saveProfile() async {
        profile.updatedAt = .now
        try? await DIContainer.shared.profileRepository.saveProfile(profile)
    }

    private func importPhoto(_ item: PhotosPickerItem?) async {
        guard let item,
              let data = try? await item.loadTransferable(type: Data.self) else { return }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("profile-\(UUID().uuidString).jpg")
        try? data.write(to: url)
        if let secure = try? DIContainer.shared.fileProtectionService.secureDirectory() {
            let dest = secure.appendingPathComponent(url.lastPathComponent)
            try? FileManager.default.copyItem(at: url, to: dest)
            profile.profilePhotoURL = dest
            await saveProfile()
        }
    }
}