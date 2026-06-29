import SwiftUI

struct SkeletonView: View {
    @State private var animate = false

    var body: some View {
        RoundedRectangle(cornerRadius: ChambeaTheme.cornerRadius)
            .fill(Color.gray.opacity(animate ? 0.2 : 0.1))
            .frame(height: 120)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    animate = true
                }
            }
            .accessibilityLabel(String(localized: "loading"))
    }
}

struct JobListSkeleton: View {
    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<5, id: \.self) { _ in
                SkeletonView()
            }
        }
        .padding()
    }
}