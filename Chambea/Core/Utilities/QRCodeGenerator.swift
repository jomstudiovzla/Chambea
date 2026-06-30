import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

enum QRCodeGenerator {
    static let installURL = AppInstallConfig.installPageURL.absoluteString
    static let repositoryURL = "https://github.com/jomstudiovzla/Chambea"

    static func image(from string: String, scale: CGFloat = 12) -> UIImage? {
        let data = Data(string.utf8)
        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(data, forKey: "inputMessage")
        filter.correctionLevel = "H"

        guard let output = filter.outputImage else { return nil }
        let transformed = output.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        let context = CIContext()
        guard let cgImage = context.createCGImage(transformed, from: transformed.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}