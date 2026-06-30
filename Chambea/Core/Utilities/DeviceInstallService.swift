import UIKit

@MainActor
enum DeviceInstallService {
    enum InstallResult {
        case openedDirectInstall
        case openedInstallPage
        case unavailable
    }

    static func installOnDevice() -> InstallResult {
        if let direct = AppInstallConfig.directInstallURL {
            UIApplication.shared.open(direct)
            return .openedDirectInstall
        }
        UIApplication.shared.open(AppInstallConfig.installPageURL)
        return .openedInstallPage
        return .unavailable
    }
}