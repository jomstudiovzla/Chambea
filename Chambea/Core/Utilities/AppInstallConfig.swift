import Foundation

enum AppInstallConfig {
    /// TestFlight public link (cuando esté disponible). Ej: https://testflight.apple.com/join/XXXXXX
    static let testFlightURL: URL? = nil

    /// Manifiesto OTA para instalación directa con un toque (requiere IPA firmado en Releases).
    static let otaManifestURL = URL(string: "https://jomstudiovzla.github.io/Chambea/manifest.plist")!

    static let installPageURL = URL(string: "https://jomstudiovzla.github.io/Chambea/install.html")!

    static var directInstallURL: URL? {
        if let testFlightURL { return testFlightURL }
        guard otaManifestURL.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) != nil else {
            return nil
        }
        let encoded = otaManifestURL.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? otaManifestURL.absoluteString
        return URL(string: "itms-services://?action=download-manifest&url=\(encoded)")
    }

    static var isDirectInstallConfigured: Bool {
        testFlightURL != nil || directInstallURL != nil
    }
}