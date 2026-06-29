import SwiftUI

struct ChambeaBadge: View {
    enum Style { case primary, secondary, neutral, success, warning }

    let text: String
    var style: Style = .neutral

    var body: some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .foregroundStyle(foregroundColor)
            .clipShape(Capsule())
    }

    private var backgroundColor: Color {
        switch style {
        case .primary: return ChambeaTheme.Colors.primary.opacity(0.15)
        case .secondary: return ChambeaTheme.Colors.secondary.opacity(0.15)
        case .success: return ChambeaTheme.Colors.success.opacity(0.15)
        case .warning: return ChambeaTheme.Colors.warning.opacity(0.15)
        case .neutral: return Color.gray.opacity(0.15)
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary: return ChambeaTheme.Colors.primary
        case .secondary: return ChambeaTheme.Colors.secondary
        case .success: return ChambeaTheme.Colors.success
        case .warning: return ChambeaTheme.Colors.warning
        case .neutral: return .secondary
        }
    }
}