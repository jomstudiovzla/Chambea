import SwiftUI

struct InstallAppView: View {
    private let installURL = URL(string: QRCodeGenerator.installURL)!
    private let repositoryURL = URL(string: QRCodeGenerator.repositoryURL)!

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                header
                qrCard
                stepsCard
                actions
            }
            .padding()
        }
        .background(ChambeaTheme.Colors.background.ignoresSafeArea())
        .navigationTitle(String(localized: "settings.install.title"))
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "iphone.and.arrow.forward")
                .font(.system(size: 36))
                .foregroundStyle(ChambeaTheme.Colors.primary)
            Text(String(localized: "settings.install.subtitle"))
                .font(ChambeaTheme.Typography.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private var qrCard: some View {
        VStack(spacing: 16) {
            Text(String(localized: "settings.install.scan"))
                .font(ChambeaTheme.Typography.headline)

            QRCodeView(content: QRCodeGenerator.installURL, size: 240)

            Text(QRCodeGenerator.installURL)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(ChambeaTheme.cardPadding)
        .background(ChambeaTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: ChambeaTheme.cornerRadius))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }

    private var stepsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(String(localized: "settings.install.how"))
                .font(ChambeaTheme.Typography.headline)

            installStep(number: 1, text: String(localized: "settings.install.step1"))
            installStep(number: 2, text: String(localized: "settings.install.step2"))
            installStep(number: 3, text: String(localized: "settings.install.step3"))

            Text(String(localized: "settings.install.note"))
                .font(ChambeaTheme.Typography.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(ChambeaTheme.cardPadding)
        .background(ChambeaTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: ChambeaTheme.cornerRadius))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }

    private var actions: some View {
        VStack(spacing: 12) {
            Link(destination: installURL) {
                Label(String(localized: "settings.install.openGuide"), systemImage: "safari")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            ShareLink(item: installURL) {
                Label(String(localized: "settings.install.share"), systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            Link(destination: repositoryURL) {
                Label(String(localized: "settings.install.repository"), systemImage: "link")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }

    private func installStep(number: Int, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.caption.weight(.bold))
                .foregroundStyle(ChambeaTheme.Colors.primary)
                .frame(width: 24, height: 24)
                .background(ChambeaTheme.Colors.primary.opacity(0.12))
                .clipShape(Circle())
            Text(text)
                .font(ChambeaTheme.Typography.body)
                .foregroundStyle(ChambeaTheme.Colors.textPrimary)
        }
    }
}