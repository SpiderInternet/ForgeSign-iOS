import SwiftUI

struct SourcesSettingsView: View {
    @EnvironmentObject private var sourceStore: SourceStore
    @Environment(\.forgeTheme) private var T
    @State private var newSourceURL = ""

    var body: some View {
        NavigationStack {
            List {
                Section("Add Source") {
                    HStack {
                        TextField("https://example.com/apps.json", text: $newSourceURL)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()

                        Button(action: addSourceAction) {
                            Text("Add")
                                .bold()
                        }
                    }
                }

                Section("Active Sources") {
                    ForEach(sourceStore.sources, id: \.self) { url in
                        Text(url.absoluteString)
                            .font(T.mono(12))
                    }
                    .onDelete(perform: removeSource)
                }
            }
            .navigationTitle("Sources")
        }
    }

    private func addSourceAction() {
        let trimmed = newSourceURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let url = URL(string: trimmed) else { return }
        sourceStore.addSource(url)
        newSourceURL = ""
    }

    private func removeSource(at offsets: IndexSet) {
        sourceStore.removeSource(at: offsets)
    }
}
