import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct DocumentsView: View {
    @StateObject private var viewModel = DocumentsViewModel()
    @State private var showDocumentPicker = false
    @State private var showPhotoPicker = false
    @State private var selectedPhoto: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.documents.isEmpty && !viewModel.isLoading {
                    EmptyStateView(
                        icon: "doc.badge.plus",
                        title: String(localized: "documents.empty.title"),
                        message: String(localized: "documents.empty.message"),
                        actionTitle: String(localized: "documents.import")
                    ) { showDocumentPicker = true }
                } else {
                    List(viewModel.documents) { doc in
                        NavigationLink {
                            DocumentPreviewView(document: doc)
                        } label: {
                            DocumentRowView(document: doc)
                        }
                    }
                }
            }
            .navigationTitle(String(localized: "documents.title"))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(String(localized: "documents.importFile")) { showDocumentPicker = true }
                        Button(String(localized: "documents.importPhoto")) { showPhotoPicker = true }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showDocumentPicker) {
                DocumentPickerView { url in
                    Task { await viewModel.importFile(from: url) }
                }
            }
            .photosPicker(isPresented: $showPhotoPicker, selection: $selectedPhoto, matching: .images)
            .onChange(of: selectedPhoto) { _, item in
                Task {
                    guard let item,
                          let data = try? await item.loadTransferable(type: Data.self) else { return }
                    await viewModel.importPhotoData(data)
                }
            }
            .task { await viewModel.load() }
        }
    }
}

struct DocumentRowView: View {
    let document: UserDocument
    var body: some View {
        HStack {
            Image(systemName: document.type.systemImage)
                .foregroundStyle(ChambeaTheme.Colors.primary)
            VStack(alignment: .leading) {
                Text(document.name).font(.headline)
                Text(document.type.displayName).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            if document.isPrimary {
                ChambeaBadge(text: String(localized: "documents.primary"), style: .success)
            }
        }
    }
}