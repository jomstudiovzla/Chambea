import Foundation

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var jobs: [Job] = []
    @Published var filter = JobFilter()
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showFilters = false
    @Published var selectedJob: Job?

    private let searchUseCase: SearchJobsUseCase
    private let jobRepository: JobRepositoryProtocol

    init(
        searchUseCase: SearchJobsUseCase = SearchJobsUseCase(repository: DIContainer.shared.jobRepository),
        jobRepository: JobRepositoryProtocol = DIContainer.shared.jobRepository
    ) {
        self.searchUseCase = searchUseCase
        self.jobRepository = jobRepository
    }

    func search() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            if jobs.isEmpty {
                let cached = try await jobRepository.getCachedJobs()
                if !cached.isEmpty { jobs = cached.filter { filter.matches($0) } }
            }
            jobs = try await searchUseCase.execute(filter: filter)
        } catch {
            errorMessage = error.localizedDescription
            if jobs.isEmpty {
                jobs = (try? await jobRepository.getCachedJobs())?.filter { filter.matches($0) } ?? []
            }
        }
    }

    func saveJob(_ job: Job) async {
        try? await jobRepository.saveJob(job, status: .saved)
    }
}