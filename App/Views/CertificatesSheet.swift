import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static var p12File: UTType {
        // Prefer system-recognized type for .p12; fall back to generic data so FileImporter allows selection
        return UTType(filenameExtension: "p12") ?? .data
    }
    static var mobileprovisionFile: UTType {
        // .mobileprovision may not have a registered UTI on all systems — allow generic data as fallback
        return UTType(filenameExtension: "mobileprovision") ?? .data
    }
}

struct CertificatesSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var certStore: CertificateStore

    @State private var showP12Importer = false
    @State private var showProvisionImporter = false
    @State private var passwordInput = ""
    @State private var showPasswordAlert = false
    @State private var selectedP12URL: URL?

    var body: some View {
        // Use a plain VStack + List to avoid nested NavigationStack inside a sheet
        let certificates = certStore.certificates

        VStack(spacing: 0) {
            // Custom header with title and close button (avoids NavigationStack)
            HStack {
                Text("الشهادات")
                    .font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Text("إغلاق")
                }
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

                        Text("إدارة الشهادات")
                            .font(.headline)

                        Text("قم بإضافة شهادة (.p12) وملف التعريف (.mobileprovision) لبدء التوقيع.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }

                Section {
                    Button(action: { showP12Importer = true }) {
                        Label("استيراد شهادة P12", systemImage: "doc.badge.plus")
                    }

                    Button(action: { showProvisionImporter = true }) {
                        Label("استيراد ملف MobileProvision", systemImage: "shield.badge.plus")
                    }
                }

                if !certificates.isEmpty {
                    CertificatesListSection(certificates: certificates, onRemove: removeCertificate)
                }
            }
        }
        .fileImporter(
            isPresented: $showP12Importer,
            allowedContentTypes: [UTType.p12File],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result, let url = urls.first {
                selectedP12URL = url
                showPasswordAlert = true
            }
        }
        .fileImporter(
            isPresented: $showProvisionImporter,
            allowedContentTypes: [UTType.mobileprovisionFile],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result, let url = urls.first {
                importProvision(from: url)
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
            Button("إلغاء", role: .cancel) {
                passwordInput = ""
            }
        } message: {
            Text("يرجى إدخال كلمة سر ملف P12 المرفق.")
        }
    }

    // MARK: - Actions routed through methods to avoid capturing certStore inside ForEach/complex closures

    private func removeCertificate(_ cert: CertificateRecord) {
        // CertificateStore provides `delete(_:)` — call that to remove the record
        certStore.delete(cert)
    }

    private func importProvision(from url: URL) {
        // There is no provisioning-profile import API on CertificateStore in this branch.
        // For now just read and store the file next to certificates (no parsing).
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
            // TODO: parse profile and extract team ID / app IDs if needed
        } catch {
            // swallow for now — there is no UI to surface errors in this view
            print("Failed to import provisioning profile: \(error)")
        }
    }

    private func importP12(from url: URL, password: String) {
        // Use the existing CertificateStore API
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
