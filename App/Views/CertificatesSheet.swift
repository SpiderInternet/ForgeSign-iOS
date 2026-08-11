import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static var p12File: UTType {
        UTType(filenameExtension: "p12") ?? UTType(exportedAs: "com.rsa.pkcs-12")
    }
    static var mobileprovisionFile: UTType {
        UTType(filenameExtension: "mobileprovision") ?? .data
    }
}

struct CertificatesSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: CertificateStore

    @State private var showP12Importer = false
    @State private var showProvisionImporter = false
    @State private var passwordInput = ""
    @State private var showPasswordAlert = false
    @State private var selectedP12URL: URL?

    var body: some View {
        NavigationStack {
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

                if !store.certificates.isEmpty {
                    Section(header: Text("الشهادات المضافة")) {
                        ForEach(store.certificates, id: \.id) { cert in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(cert.name)
                                        .font(.body)
                                        .fontWeight(.semibold)
                                    
                                    if let exp = cert.expirationDate, !exp.isEmpty {
                                        Text(exp)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Button(role: .destructive, action: { 
                                    store.removeCertificate(cert) 
                                }) {
                                    Image(systemName: "trash")
                                }
                                .buttonStyle(.plain)
                                .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            .navigationTitle("الشهادات")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("إغلاق") { dismiss() }
                }
            }
            .fileImporter(
                isPresented: $showP12Importer,
                allowedContentTypes: [.p12File, .data, .item],
                allowsMultipleSelection: false
            ) { result in
                if case .success(let urls) = result, let url = urls.first {
                    selectedP12URL = url
                    showPasswordAlert = true
                }
            }
            .fileImporter(
                isPresented: $showProvisionImporter,
                allowedContentTypes: [.mobileprovisionFile, .data, .item],
                allowsMultipleSelection: false
            ) { result in
                if case .success(let urls) = result, let url = urls.first {
                    store.importProvisioningProfile(from: url)
                }
            }
            .alert("كلمة سر الشهادة", isPresented: $showPasswordAlert) {
                SecureField("أدخل كلمة السر", text: $passwordInput)
                Button("استيراد") {
                    if let url = selectedP12URL {
                        store.importP12(from: url, password: passwordInput)
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
    }
}
