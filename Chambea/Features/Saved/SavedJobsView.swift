import SwiftUI

struct SavedJobsView: View {
    @State private var savedJobs: [SavedJob] = []
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    JobListSkeleton()
                } else if savedJobs.isEmpty {
                    EmptyStateView(
                        icon: "bookmark",
                        title: String(localized: "saved.empty.title"),
                        message: String(localized: "saved.empty.message")
                    )
                } else {
                    List(savedJobs) { saved in
                        NavigationLink {
                            JobDetailView(job: saved.job)
                        } label: {
                            HStack(spacing: 12) {
                                CompanyLogoView(company: saved.job.company, logoURL: saved.job.logoURL, size: 44)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(saved.job.title).font(.headline).lineLimit(2)
                                    Text(saved.job.company).font(.caption).foregroundStyle(.secondary)
                                    ChambeaBadge(text: saved.status.displayName, style: .primary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle(String(localized: "saved.title"))
            .task { await load() }
            .refreshable { await load() }
        }
    }

    private func load() async {
        isLoading = true
        defer { isLoading = false }
        savedJobs = (try? await DIContainer.shared.jobRepository.getSavedJobs()) ?? []
    }
}