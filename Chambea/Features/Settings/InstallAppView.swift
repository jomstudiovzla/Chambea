import SwiftUI

struct InstallAppView: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 12) {
                Image(systemName: "briefcase.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(ChambeaTheme.Colors.primary)
                Text("Chambea")
                    .font(ChambeaTheme.Typography.title)
                Text(String(localized: "settings.install.oneTap.subtitle"))
                    .font(ChambeaTheme.Typography.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            InstallOnDeviceButton()

            Text(String(localized: "settings.install.oneTap.hint"))
                .font(ChambeaTheme.Typography.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ChambeaTheme.Colors.background.ignoresSafeArea())
        .navigationTitle(String(localized: "settings.install.title"))
        .navigationBarTitleDisplayMode(.inline)
    }
}