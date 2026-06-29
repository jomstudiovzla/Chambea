import SwiftUI
import PhotosUI
import AVKit

struct PresentationVideoView: View {
    @Binding var profile: UserProfile
    var onSave: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selectedVideo: PhotosPickerItem?
    @State private var isImporting = false
    @State private var importError: String?

    var body: some View {
        Form {
            languageSection
            uploadSection
            previewSection
            saveSection
        }
        .navigationTitle(String(localized: "profile.section.video"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(String(localized: "cancel")) { dismiss() }
            }
        }
        .onChange(of: selectedVideo) { _, item in
            Task { await importVideo(item) }
        }
    }

    private var languageSection: some View {
        Section(String(localized: "profile.video.language.title")) {
            Picker(String(localized: "profile.video.language.title"), selection: $profile.presentationVideoLanguage) {
                Text(PresentationVideoLanguage.spanish.displayName).tag(PresentationVideoLanguage.spanish)
                Text(PresentationVideoLanguage.english.displayName).tag(PresentationVideoLanguage.english)
                Text(PresentationVideoLanguage.bilingual.displayName).tag(PresentationVideoLanguage.bilingual)
            }
        }
    }

    private var uploadSection: some View {
        Section(String(localized: "profile.video.upload")) {
            PhotosPicker(selection: $selectedVideo, matching: .videos) {
                Label(String(localized: "profile.video.pick"), systemImage: "photo.on.rectangle")
            }

            if isImporting {
                ProgressView(String(localized: "profile.video.importing"))
            }

            if let error = importError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }

    @ViewBuilder
    private var previewSection: some View {
        if let url = profile.presentationVideoURL {
            Section(String(localized: "profile.video.preview")) {
                VideoPlayer(player: AVPlayer(url: url))
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: ChambeaTheme.cornerRadius))

                Button(String(localized: "profile.video.remove"), role: .destructive) {
                    profile.presentationVideoURL = nil
                }
            }
        }
    }

    private var saveSection: some View {
        Section {
            PrimaryButton(title: String(localized: "save"), action: {
                onSave()
                dismiss()
            })
        }
    }

    private func importVideo(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        isImporting = true
        importError = nil
        defer { isImporting = false }

        do {
            guard let data = try await item.loadTransferable(type: Data.self) else {
                importError = String(localized: "profile.video.error")
                return
            }

            let maxBytes = 100 * 1024 * 1024
            guard data.count <= maxBytes else {
                importError = String(localized: "profile.video.tooLarge")
                return
            }

            guard let secure = try? DIContainer.shared.fileProtectionService.secureDirectory() else {
                importError = String(localized: "profile.video.error")
                return
            }

            let filename = "pitch-\(UUID().uuidString).mp4"
            let destination = secure.appendingPathComponent(filename)
            try data.write(to: destination, options: .atomic)
            profile.presentationVideoURL = destination
        } catch {
            importError = String(localized: "profile.video.error")
        }
    }
}