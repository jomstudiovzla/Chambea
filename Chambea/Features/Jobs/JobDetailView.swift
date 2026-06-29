import SwiftUI
import SafariServices

struct JobDetailView: View {
    let job: Job
    @State private var showSafari = false
    @State private var showMessaging = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                tagsSection
                descriptionSection
                actions
            }
            .padding()
        }
        .navigationTitle(job.title)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSafari) {
            if let url = job.applyURL ?? job.sourceURL as URL? {
                SafariView(url: url)
            }
        }
        .sheet(isPresented: $showMessaging) {
            MessagingView(job: job)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                CompanyLogoView(company: job.company, logoURL: job.logoURL, size: 64)
                VStack(alignment: .leading, spacing: 4) {
                    Text(job.company)
                        .font(ChambeaTheme.Typography.title)
                    Text(job.title)
                        .font(ChambeaTheme.Typography.caption)
                        .foregroundStyle(.secondary)
                }
            }
            HStack {
                ChambeaBadge(text: job.remoteType.displayName, style: .primary)
                ChambeaBadge(text: job.contractType.displayName, style: .neutral)
                if let salary = job.salaryDisplay {
                    ChambeaBadge(text: salary, style: .success)
                }
            }
            languageBadges
            Label(job.location, systemImage: "mappin.and.ellipse")
                .foregroundStyle(.secondary)
        }
    }

    private var languageBadges: some View {
        HStack {
            ForEach(languageLabels, id: \.self) { label in
                ChambeaBadge(text: label, style: .primary)
            }
            if job.source.isPortal {
                ChambeaBadge(text: String(localized: "source.portal"), style: .neutral)
            }
        }
    }

    private var languageLabels: [String] {
        let categories = JobLanguageDetector.categories(for: job)
        return categories.filter { $0 != .any }.map(\.displayName)
    }

    private var tagsSection: some View {
        FlowLayout(spacing: 8) {
            ForEach(job.tags, id: \.self) { tag in
                ChambeaChip(text: tag)
            }
        }
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(String(localized: "job.description"))
                .font(ChambeaTheme.Typography.headline)
            Text(job.description.strippingHTML())
                .font(ChambeaTheme.Typography.body)
        }
    }

    private var actions: some View {
        VStack(spacing: 12) {
            PrimaryButton(title: job.source.isPortal ? String(localized: "job.openPortal") : String(localized: "job.apply")) {
                showSafari = true
            }
            Button(String(localized: "job.contact")) { showMessaging = true }
                .buttonStyle(.bordered)
            NavigationLink(String(localized: "ai.interview")) {
                AIInterviewView(job: job)
            }
            .buttonStyle(.bordered)
        }
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }
    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
        return (CGSize(width: maxWidth, height: y + rowHeight), positions)
    }
}