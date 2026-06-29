import SwiftUI

struct JobCardView: View {
    let job: Job
    var onSave: (() -> Void)?
    var onTap: (() -> Void)?

    var body: some View {
        Button(action: { onTap?() }) {
            VStack(alignment: .leading, spacing: ChambeaTheme.spacing) {
                HStack(alignment: .top, spacing: 12) {
                    CompanyLogoView(company: job.company, logoURL: job.logoURL, size: 52)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(job.title)
                            .font(ChambeaTheme.Typography.headline)
                            .foregroundStyle(ChambeaTheme.Colors.textPrimary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                        Text(job.company)
                            .font(ChambeaTheme.Typography.caption)
                            .foregroundStyle(ChambeaTheme.Colors.textSecondary)
                            .lineLimit(1)
                    }
                    Spacer(minLength: 0)
                }

                HStack(spacing: 8) {
                    ChambeaBadge(text: job.remoteType.displayName, style: .primary)
                    if let salary = job.salaryDisplay {
                        ChambeaBadge(text: salary, style: .secondary)
                    }
                    ChambeaBadge(text: job.seniority.displayName, style: .neutral)
                }

                if !job.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(job.tags.prefix(5), id: \.self) { tag in
                                ChambeaChip(text: tag)
                            }
                        }
                    }
                }

                HStack {
                    Label(job.source.displayName, systemImage: "link")
                        .font(ChambeaTheme.Typography.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button(action: { onSave?() }) {
                        Image(systemName: "bookmark")
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(String(localized: "job.save"))
                }
            }
            .padding(ChambeaTheme.cardPadding)
            .background(ChambeaTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: ChambeaTheme.cornerRadius))
            .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }
}