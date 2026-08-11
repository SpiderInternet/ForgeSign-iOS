import SwiftUI

struct LibraryView: View {
    @Environment(\.forgeTheme) private var T
    @State private var selectedIPAURL: URL?
    @State private var showingFilePicker = false
    @State private var errorMessage: String?
    @State private var showErrorAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(spacing: 12) {
                            Image(systemName: "doc.badge.plus")
                                .font(.system(size: 48))
                                .foregroundColor(T.accent)

                            Text("Select IPA File")
                                .font(T.sans(18, .bold))
                                .foregroundColor(T.ink)

                            Text("Choose an IPA file from your device to prepare for signing.")
                                .font(T.sans(13, .regular))
                                .foregroundColor(T.ink3)
                                .multilineTextAlignment(.center)

                            Button(action: { showingFilePicker = true }) {
                                Label("Browse Files", systemImage: "folder.fill")
                                    .font(T.sans(14, .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(T.accent)
                                    .cornerRadius(12)
                            }
                            .padding(.top, 8)
                        }
                        .padding(20)
                        .fGlass(cornerRadius: 18)
                        .padding(.horizontal, 16)

                        if let url = selectedIPAURL {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Selected File")
                                    .font(T.sans(14, .bold))
                                    .foregroundColor(T.ink)

                                Text(url.lastPathComponent)
                                    .font(T.mono(12))
                                    .foregroundColor(T.ink2)
                                    .lineLimit(1)
                            }
                            .padding(16)
                            .fGlass(cornerRadius: 14)
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.top, 20)
                }
                .background { ForgeBackdrop() }
                .navigationTitle("Sign IPA")
                .sheet(isPresented: $showingFilePicker) {
                    DocumentPicker(selectedURL: $selectedIPAURL, onError: { err in
                        self.errorMessage = err
                        self.showErrorAlert = true
                    })
                }
                .alert("Error", isPresented: $showErrorAlert) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(errorMessage ?? "Unknown error occurred.")
                }
            }
        }
    }
}

// MARK: - Safe Document Picker Component

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var selectedURL: URL?
    var onError: (String) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.item], asCopy: true)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker

        init(_ parent: DocumentPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else {
                parent.onError("No file was selected.")
                return
            }

            guard url.startAccessingSecurityScopedResource() else {
                // If direct security access fails, still keep reference safely
                parent.selectedURL = url
                return
            }

            defer { url.stopAccessingSecurityScopedResource() }
            parent.selectedURL = url
        }
    }
}
