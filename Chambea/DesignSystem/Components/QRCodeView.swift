import SwiftUI

struct QRCodeView: View {
    let content: String
    var size: CGFloat = 220

    var body: some View {
        Group {
            if let uiImage = QRCodeGenerator.image(from: content) {
                Image(uiImage: uiImage)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
            } else {
                RoundedRectangle(cornerRadius: ChambeaTheme.cornerRadius)
                    .fill(ChambeaTheme.Colors.surface)
                    .overlay {
                        Image(systemName: "qrcode")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                    }
            }
        }
        .frame(width: size, height: size)
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: ChambeaTheme.cornerRadius))
        .shadow(color: .black.opacity(0.08), radius: 10, y: 4)
    }
}