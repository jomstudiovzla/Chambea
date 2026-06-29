import SwiftUI

struct FilterSheetView: View {
    @Binding var filter: JobFilter
    let onApply: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(String(localized: "filter.languages")) {
                    ForEach(JobLanguage.allCases.filter { $0 != .any }, id: \.self) { language in
                        Toggle(language.displayName, isOn: setBinding(\.jobLanguages, value: language))
                    }
                }
                Section(String(localized: "filter.markets")) {
                    ForEach(TargetMarket.allCases, id: \.self) { market in
                        Toggle(market.displayName, isOn: setBinding(\.targetMarkets, value: market))
                    }
                }
                Section(String(localized: "filter.remote")) {
                    Toggle(String(localized: "filter.remoteOnly"), isOn: $filter.remoteOnly)
                    ForEach(RemoteType.allCases, id: \.self) { type in
                        Toggle(type.displayName, isOn: setBinding(\.remoteTypes, value: type))
                    }
                }
                Section(String(localized: "filter.seniority")) {
                    ForEach(Seniority.allCases, id: \.self) { level in
                        Toggle(level.displayName, isOn: setBinding(\.seniorities, value: level))
                    }
                }
                Section(String(localized: "filter.contract")) {
                    ForEach(ContractType.allCases, id: \.self) { type in
                        Toggle(type.displayName, isOn: setBinding(\.contractTypes, value: type))
                    }
                }
                Section(String(localized: "filter.sources")) {
                    ForEach(JobSource.allCases, id: \.self) { source in
                        Toggle(source.displayName, isOn: setBinding(\.sources, value: source))
                    }
                }
                Section(String(localized: "filter.salary")) {
                    TextField(String(localized: "filter.salaryMin"), value: $filter.salaryMin, format: .number)
                        .keyboardType(.numberPad)
                    TextField(String(localized: "filter.salaryMax"), value: $filter.salaryMax, format: .number)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle(String(localized: "filter.title"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "apply")) {
                        onApply()
                        dismiss()
                    }
                }
            }
        }
    }

    private func setBinding<T: Hashable>(_ keyPath: WritableKeyPath<JobFilter, Set<T>>, value: T) -> Binding<Bool> {
        Binding(
            get: { filter[keyPath: keyPath].contains(value) },
            set: { isOn in
                if isOn {
                    filter[keyPath: keyPath].insert(value)
                } else {
                    filter[keyPath: keyPath].remove(value)
                }
            }
        )
    }
}