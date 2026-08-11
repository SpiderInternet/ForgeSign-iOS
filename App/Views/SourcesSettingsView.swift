import SwiftUI

struct SourcesSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.forgeTheme) private var T
    @EnvironmentObject private var sourceStore: SourceStore
    
    @State private var newSourceURL: String = ""

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("المصادر المضافة").font(T.sans(12, .bold))) {
                    ForEach(sourceStore.sources, id: \.self) { urlString in
                        Text(urlString)
                            .font(T.sans(14, .regular))
                            .foregroundColor(T.ink)
                    }
                    .onDelete { offsets in
                        sourceStore.removeSource(at: offsets)
                    }
                }
                
                Section(header: Text("إضافة سورس جديد").font(T.sans(12, .bold))) {
                    HStack {
                        TextField("https://...", text: $newSourceURL)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                        
                        Button("إضافة") {
                            guard !newSourceURL.isEmpty else { return }
                            sourceStore.addSource(newSourceURL)
                            newSourceURL = ""
                        }
                        .font(T.sans(14, .bold))
                        .foregroundColor(T.accent)
                    }
                }
            }
            .navigationTitle("إدارة المصادر")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("تم") { dismiss() }
                        .font(T.sans(14, .bold))
                        .foregroundColor(T.accent)
                }
            }
        }
    }
}
