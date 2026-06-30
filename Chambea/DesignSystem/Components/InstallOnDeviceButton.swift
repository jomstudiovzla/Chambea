import SwiftUI

struct InstallOnDeviceButton: View {
    var style: Style = .prominent
    @State private var isInstalling = false
    @State private var showUnavailable = false

    enum Style {
        case prominent
        case settingsRow
    }

    var body: some View {
        Group {
            switch style {
            case .prominent:
                prominentButton
            case .settingsRow:
                settingsButton
            }
        }
        .alert(String(localized: "settings.install.unavailable.title"), isPresented: $showUnavailable) {
            Button(String(localized: "ok"), role: .cancel) {}
        } message: {
            Text(String(localized: "settings.install.unavailable.message"))
        }
    }

    private var prominentButton: some View {
        Button {
            performInstall()
        } label: {
            HStack(spacing: 10) {
                if isInstalling {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.title3)
                }
                Text(String(localized: "settings.install.oneTap"))
                    .font(ChambeaTheme.Typography.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .foregroundStyle(.white)
            .background(ChambeaTheme.Colors.primary)
            .clipShape(RoundedRectangle(cornerRadius: ChambeaTheme.cornerRadius))
            .shadow(color: ChambeaTheme.Colors.primary.opacity(0.35), radius: 12, y: 6)
        }
        .disabled(isInstalling)
    }

    private var settingsButton: some View {
        Button {
            performInstall()
        } label: {
            Label(String(localized: "settings.install.oneTap"), systemImage: "arrow.down.circle.fill")
        }
    }

    private func performInstall() {
        isInstalling = true
        let result = DeviceInstallService.installOnDevice()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isInstalling = false
            if result == .unavailable {
                showUnavailable = true
            }
        }
    }
}