import Foundation

enum AppInstallConfig {
    /// TestFlight public link (cuando esté disponible). Ej: https://testflight.apple.com/join/XXXXXX
    static let testFlightURL: URL? = nil

    /// Manifiesto OTA para instalación directa con un toque (requiere IPA firmado en Releases).
    static let otaManifestURL = URL(string: "https://jomstudiovzla.github.io/Chambea/manifest.plist")!

    /// URL del IPA publicado en GitHub Releases. Debe existir (HTTP 200) para activar OTA.
    static let otaPackageURL = URL(string: "https://github.com/jomstudiovzla/Chambea/releases/download/v1.0.0/Chambea.ipa")!

    /// Cambiar a `true` solo después de publicar el IPA firmado en Releases.
    static let otaPackagePublished = false

    static let installPageURL = URL(string: "https://jomstudiovzla.github.io/Chambea/install.html")!

    static var directInstallURL: URL? {
        if let testFlightURL { return testFlightURL }
        guard otaPackagePublished else { return nil }
        let encoded = otaManifestURL.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            ?? otaManifestURL.absoluteString
        return URL(string: "itms-services://?action=download-manifest&url=\(encoded)")
    }

    static var isDirectInstallConfigured: Bool {
        directInstallURL != nil
    }
}