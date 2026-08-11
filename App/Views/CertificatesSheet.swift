import SwiftUI
import UniformTypeIdentifiers
import UIKit

extension UTType {
    static var p12File: UTType {
        UTType(filenameExtension: "p12") ?? .data
    }
    static var mobileprovisionFile: UTType {
        UTType(filenameExtension: "mobileprovision") ?? .data
    }
}

// UIKit-based document picker wrapper (more permissive across providers)
private struct DocumentPicker: UIViewControllerRepresentable {
    let contentTypes: [UTType]
    let onPick: (URL) -> Void
    let onCancel: () -> Void

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: contentTypes, asCopy: true)
        controller.delegate = context.coordinator
        controller.allowsMultipleSelection = false
        return controller
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) { }

    final class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        init(_ parent: DocumentPicker) { self.parent = parent }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.onCancel()
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            parent.onPick(url)
        }
    }
}

struct CertificatesSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var certStore: CertificateStore

    private enum ImporterKind {
        case p12
        case provision
    }

    @State private var activeImporter: ImporterKind? = nil
    @State private var passwordInput = ""
    @State private var showPasswordAlert = false
    @State private var selectedP12URL: URL?

    @State private var invalidSelectionMessage: String = ""
    @State private var showInvalidSelectionAlert = false
    @State private var presentDocumentPicker = false

    var body: some View {
        let certificates = certStore.certificates

        VStack(spacing: 0) {
            HStack {
                Text("الشهادات").font(.headline)
                Spacer()
                Button(action: { dismiss() }) { Text("إغلاق") }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            List {
                Section {
                    VStack(spacing: 8) {
                        Image(systemName: "key.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)

                        Text("إدارة الشهادات").font(.headline)

                        Text("قم بإضافة شهادة (.p12) وملف التعريف (.mobileprovision) لبدء التوقيع.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }

                Section {
                    Button(action: {
                        activeImporter = .p12
                        presentDocumentPicker = true
                    }) {
                        Label("استيراد شهادة P12", systemImage: "doc.badge.plus")
                    }

                    Button(action: {
                        activeImporter = .provision
                        presentDocumentPicker = true
                    }) {
                        Label("استيراد ملف MobileProvision", systemImage: "shield.badge.plus")
                    }
                }

                if !certificates.isEmpty {
                    CertificatesListSection(certificates: certificates, onRemove: removeCertificate)
                }
            }
        }
        // Present UIKit DocumentPicker when requested (more compatible with providers)
        .sheet(isPresented: $presentDocumentPicker) {
            if let kind = activeImporter {
                DocumentPicker(contentTypes: documentTypes(for: kind), onPick: { url in
                    presentDocumentPicker = false
                    handlePicked(url: url)
                }, onCancel: {
                    presentDocumentPicker = false
                    activeImporter = nil
                })
                .edgesIgnoringSafeArea(.all)
            } else {
                EmptyView()
            }
        }
        .alert("كلمة سر الشهادة", isPresented: $showPasswordAlert) {
            SecureField("أدخل كلمة السر", text: $passwordInput)
            Button("استيراد") {
                if let url = selectedP12URL {
                    importP12(from: url, password: passwordInput)
                    passwordInput = ""
                }
            }
            Button("إلغاء", role: .cancel) { passwordInput = "" }
        } message: { Text("يرجى إدخال كلمة سر ملف P12 المرفق.") }
        .alert("ملف غير صالح", isPresented: $showInvalidSelectionAlert) {
            Button("حسنًا", role: .cancel) { showInvalidSelectionAlert = false }
        } message: { Text(invalidSelectionMessage) }
    }

    private func documentTypes(for kind: ImporterKind) -> [UTType] {
        switch kind {
        case .p12:
            return [UTType.p12File, .data, .item]
        case .provision:
            return [UTType.mobileprovisionFile, .data, .item]
        }
    }

    private func handlePicked(url: URL) {
        let ext = url.pathExtension.lowercased()
        switch activeImporter {
        case .p12:
            if ext == "p12" {
                selectedP12URL = url
                showPasswordAlert = true
            } else {
                invalidSelectionMessage = "الملف المحدد ليس بلاحقة .p12: \(url.lastPathComponent)"
                showInvalidSelectionAlert = true
            }
        case .provision:
            if ext == "mobileprovision" {
                importProvision(from: url)
            } else {
                invalidSelectionMessage = "الملف المحدد ليس بلاحقة .mobileprovision: \(url.lastPathComponent)"
                showInvalidSelectionAlert = true
            }
        case .none:
            break
        }
        activeImporter = nil
    }

    private func removeCertificate(_ cert: CertificateRecord) { certStore.delete(cert) }

    private func importProvision(from url: URL) {
        let scoped = url.startAccessingSecurityScopedResource()
        defer { if scoped { url.stopAccessingSecurityScopedResource() } }

        do {
            let data = try Data(contentsOf: url)
            let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            let profilesDir = base.appendingPathComponent("Profiles", isDirectory: true)
            try FileManager.default.createDirectory(at: profilesDir, withIntermediateDirectories: true)
            var filename = url.lastPathComponent
            if FileManager.default.fileExists(atPath: profilesDir.appendingPathComponent(filename).path) {
                let stem = url.deletingPathExtension().lastPathComponent
                let short = UUID().uuidString.prefix(6)
                filename = "\(stem)-\(short).\(url.pathExtension)"
            }
            let dest = profilesDir.appendingPathComponent(filename)
            try data.write(to: dest, options: .completeFileProtection)
        } catch {
            invalidSelectionMessage = "فشل استيراد ملف التعريف: \(error.localizedDescription)"
            showInvalidSelectionAlert = true
        }
    }

    private func importP12(from url: URL, password: String) {
        let scoped = url.startAccessingSecurityScopedResource()
        defer { if scoped { url.stopAccessingSecurityScopedResource() } }
        _ = certStore.importCertificate(from: url, password: password, rememberPassword: false)
    }
}

private struct CertificatesListSection: View {
    let certificates: [CertificateRecord]
    let onRemove: (CertificateRecord) -> Void

    var body: some View {
        Section(header: Text("الشهادات المضافة")) {
            ForEach(certificates, id: \.id) { cert in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(cert.displayName)
                            .font(.body)
                            .fontWeight(.semibold)

                        if let exp = cert.notAfter {
                            Text(exp, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Spacer()

                    Button(role: .destructive) {
                        onRemove(cert)
                    } label: {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.red)
                }
            }
        }
    }
}
