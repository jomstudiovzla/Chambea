import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar
                filterBar
                content
            }
            .navigationTitle(String(localized: "search.title"))
            .sheet(isPresented: $viewModel.showFilters) {
                FilterSheetView(filter: $viewModel.filter) {
                    Task { await viewModel.search() }
                }
            }
            .navigationDestination(item: $viewModel.selectedJob) { job in
                JobDetailView(job: job)
            }
            .task { await viewModel.search() }
            .refreshable { await viewModel.search() }
        }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField(String(localized: "search.placeholder"), text: $viewModel.filter.query)
                .textInputAutocapitalization(.never)
                .onSubmit { Task { await viewModel.search() } }
            if !viewModel.filter.query.isEmpty {
                Button(action: {
                    viewModel.filter.query = ""
                    Task { await viewModel.search() }
                }) {
                    Image(systemName: "xmark.circle.fill")
                }
            }
        }
        .padding(12)
        .background(ChambeaTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding()
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                Button(action: { viewModel.showFilters = true }) {
                    Label(String(localized: "filter.title"), systemImage: "line.3.horizontal.decrease.circle")
                }
                .buttonStyle(.bordered)
                ChambeaChip(text: String(localized: "language.spanish"), isSelected: viewModel.filter.jobLanguages.contains(.spanish)) {
                    toggleLanguage(.spanish)
                }
                ChambeaChip(text: String(localized: "market.latam"), isSelected: viewModel.filter.targetMarkets.contains(.latam)) {
                    toggleMarket(.latam)
                }
                ChambeaChip(text: String(localized: "market.venezuela"), isSelected: viewModel.filter.targetMarkets.contains(.venezuela)) {
                    toggleMarket(.venezuela)
                }
                ChambeaChip(text: String(localized: "remote.fully"), isSelected: viewModel.filter.remoteOnly) {
                    viewModel.filter.remoteOnly.toggle()
                    Task { await viewModel.search() }
                }
                ForEach(JobSortOption.allCases, id: \.self) { option in
                    ChambeaChip(text: option.displayName, isSelected: viewModel.filter.sortBy == option) {
                        viewModel.filter.sortBy = option
                        Task { await viewModel.search() }
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.jobs.isEmpty {
            JobListSkeleton()
        } else if let error = viewModel.errorMessage, viewModel.jobs.isEmpty {
            EmptyStateView(
                icon: "wifi.exclamationmark",
                title: String(localized: "error.title"),
                message: error,
                actionTitle: String(localized: "retry")
            ) { Task { await viewModel.search() } }
        } else if viewModel.jobs.isEmpty {
            EmptyStateView(
                icon: "briefcase",
                title: String(localized: "search.empty.title"),
                message: String(localized: "search.empty.message"),
                actionTitle: String(localized: "filter.title")
            ) { viewModel.showFilters = true }
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.jobs) { job in
                        JobCardView(job: job, onSave: { Task { await viewModel.saveJob(job) } }) {
                            viewModel.selectedJob = job
                        }
                    }
                }
                .padding()
            }
        }
    }

    private func toggleLanguage(_ language: JobLanguage) {
        if viewModel.filter.jobLanguages.contains(language) {
            viewModel.filter.jobLanguages.remove(language)
        } else {
            viewModel.filter.jobLanguages.insert(language)
        }
        Task { await viewModel.search() }
    }

    private func toggleMarket(_ market: TargetMarket) {
        if viewModel.filter.targetMarkets.contains(market) {
            viewModel.filter.targetMarkets.remove(market)
        } else {
            viewModel.filter.targetMarkets.insert(market)
        }
        Task { await viewModel.search() }
    }
}