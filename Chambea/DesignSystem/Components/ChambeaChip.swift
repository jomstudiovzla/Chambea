import SwiftUI

struct ChambeaChip: View {
    let text: String
    var isSelected: Bool = false
    var onTap: (() -> Void)?

    var body: some View {
        Button(action: { onTap?() }) {
            Text(text)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? ChambeaTheme.Colors.primary : Color.gray.opacity(0.12))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}