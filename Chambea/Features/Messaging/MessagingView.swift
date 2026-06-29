import SwiftUI

struct MessagingView: View {
    let job: Job
    @State private var subject = ""
    @State private var messageBody = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(String(localized: "message.recipient")) {
                    Text(job.company)
                }
                Section(String(localized: "message.subject")) {
                    TextField(String(localized: "message.subject.placeholder"), text: $subject)
                }
                Section(String(localized: "message.body")) {
                    TextEditor(text: $messageBody)
                        .frame(minHeight: 150)
                }
                Section {
                    if job.applyURL != nil {
                        Button(String(localized: "message.openApply")) {
                            if let url = job.applyURL { UIApplication.shared.open(url) }
                        }
                    }
                    Button(String(localized: "message.sendEmail")) {
                        sendEmail()
                    }
                    .disabled(subject.isEmpty || messageBody.isEmpty)
                }
            }
            .navigationTitle(String(localized: "message.title"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "close")) { dismiss() }
                }
            }
        }
    }

    private func sendEmail() {
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = messageBody.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "mailto:?subject=\(encodedSubject)&body=\(encodedBody)") {
            UIApplication.shared.open(url)
        }
    }
}