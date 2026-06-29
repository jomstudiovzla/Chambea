import SwiftUI

enum ChambeaTheme {
    static let cornerRadius: CGFloat = 16
    static let cardPadding: CGFloat = 16
    static let spacing: CGFloat = 12

    enum Colors {
        static let primary = Color("PrimaryColor")
        static let secondary = Color("SecondaryColor")
        static let background = Color("BackgroundColor")
        static let surface = Color("SurfaceColor")
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red
    }

    enum Typography {
        static let largeTitle = Font.system(.largeTitle, design: .rounded).weight(.bold)
        static let title = Font.system(.title2, design: .rounded).weight(.semibold)
        static let headline = Font.system(.headline, design: .rounded)
        static let body = Font.system(.body, design: .default)
        static let caption = Font.system(.caption, design: .default)
    }
}