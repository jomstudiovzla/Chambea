import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            Text(String(localized: "privacy.policy.content"))
                .padding()
        }
        .navigationTitle(String(localized: "settings.privacy.policy"))
    }
}