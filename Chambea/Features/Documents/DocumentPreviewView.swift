import SwiftUI
import PDFKit
import AVKit

struct DocumentPreviewView: View {
    let document: UserDocument
    @State private var showShare = false

    var body: some View {
        VStack {
            previewContent
            HStack {
                Button(String(localized: "documents.export")) { showShare = true }
                    .buttonStyle(.borderedProminent)
                ShareLink(item: document.localURL) {
                    Label(String(localized: "share"), systemImage: "square.and.arrow.up")
                }
            }
            .padding()
        }
        .navigationTitle(document.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var previewContent: some View {
        switch document.type {
        case .image:
            if let uiImage = UIImage(contentsOfFile: document.localURL.path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            }
        case .cv, .coverLetter, .certificate, .other:
            if document.mimeType.contains("pdf") {
                PDFKitView(url: document.localURL)
            } else {
                Text(String(localized: "documents.previewUnavailable"))
            }
        case .video:
            VideoPlayer(player: AVPlayer(url: document.localURL))
        case .portfolio:
            Text(String(localized: "documents.portfolioPreview"))
        }
    }
}

struct PDFKitView: UIViewRepresentable {
    let url: URL
    func makeUIView(context: Context) -> PDFView {
        let view = PDFView()
        view.document = PDFDocument(url: url)
        view.autoScales = true
        return view
    }
    func updateUIView(_ uiView: PDFView, context: Context) {}
}