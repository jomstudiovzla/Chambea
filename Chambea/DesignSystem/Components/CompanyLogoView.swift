import SwiftUI

struct CompanyLogoView: View {
    let company: String
    var logoURL: URL?
    var size: CGFloat = 48

    var body: some View {
        Group {
            if let logoURL {
                AsyncImage(url: logoURL) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .failure:
                        initialsView
                    default:
                        ProgressView()
                    }
                }
            } else {
                initialsView
            }
        }
        .frame(width: size, height: size)
        .background(ChambeaTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.22))
        .overlay(
            RoundedRectangle(cornerRadius: size * 0.22)
                .stroke(Color.gray.opacity(0.12), lineWidth: 1)
        )
    }

    private var initialsView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.22)
                .fill(
                    LinearGradient(
                        colors: [
                            ChambeaTheme.Colors.primary.opacity(0.85),
                            ChambeaTheme.Colors.secondary.opacity(0.75)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Text(String(company.prefix(1)).uppercased())
                .font(.system(size: size * 0.42, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
    }
}