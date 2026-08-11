import SwiftUI
import UniformTypeIdentifiers

// تعريف أنواع الملفات لضمان التوافق التام مع تطبيق الملفات
extension UTType {
    static var p12File: UTType {
        UTType(filenameExtension: "p12") ?? UTType(exportedAs: "com.rsa.pkcs-12")
    }
    static var mobileprovisionFile: UTType {
        UTType(filenameExtension: "mobileprovision") ?? .data
    }
}

// مكون فرعي مستقل لعرض حقل الشهادة وتسهيل المعالجة على المترجم
struct CertificateRowView: View {
    let name: String
    let date: String
    let onDelete: () -> Void
    @Environment(\.forgeTheme) private var T

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(T.sans(14, .bold))
                    .foregroundColor(T.ink)
                Text(date)
                    .font(T.sans(12, .regular))
                    .foregroundColor(T.ink3)
            }
            Spacer()
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding(12)
        .fGlass(cornerRadius: 10)
    }
}

struct CertificatesSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.forgeTheme) private var T
    @EnvironmentObject private var store: CertificateStore

    @State private var showP12Importer = false
    @State private var showProvisionImporter = false
    @State private var passwordInput = ""
    @State private var showPasswordAlert = false
    @State private var selectedP12URL: URL?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // 1. بطاقة الهيدر التوضيحية
                    VStack(spacing: 12) {
                        Image(systemName: "key.fill")
                            .font(.system(size: 44))
                            .foregroundColor(T.accent)
                        
                        Text("إدارة الشهادات")
                            .font(T.sans(20, .bold))
                            .foregroundColor(T.ink)
                        
                        Text("قم بإضافة شهادة (.p12) وملف التعريف (.mobileprovision) لبدء التوقيع.")
                            .font(T.sans(13, .regular))
                            .foregroundColor(T.ink2)
                            .multilineTextAlignment(.center)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .fGlass(cornerRadius: 16)

                    // 2. أزرار الاستيراد المباشرة
                    VStack(spacing: 12) {
                        Button(action: { showP12Importer = true }) {
                            HStack {
                                Image(systemName: "doc.badge.plus")
                                    .font(.system(size: 18, weight: .bold))
                                Text("استيراد شهادة P12")
                                    .font(T.sans(15, .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(T.accent)
                            .cornerRadius(12)
                        }

                        Button(action: { showProvisionImporter = true }) {
                            HStack {
                                Image(systemName: "shield.badge.plus")
                                    .font(.system(size: 18, weight: .bold))
                                Text("استيراد ملف MobileProvision")
                                    .font(T.sans(15, .bold))
                            }
                            .foregroundColor(T.accent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(T.accent.opacity(0.15))
                            .cornerRadius(12)
                        }
                    }

                    // 3. قائمة الشهادات المستوردة
                    if !store.certificates.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("الشهادات المضافة")
                                .font(T.sans(16, .bold))
                                .foregroundColor(T.ink)

                            ForEach(store.certificates, id: \.id) { cert in
                                CertificateRowView(
                                    name: cert.name,
                                    date: cert.expirationDate ?? "",
                                    onDelete: { store.removeCertificate(cert) }
                                )
                            }
                        }
                        .padding(.top, 10)
                    }
                }
                .padding(16)
            }
            .background { ForgeBackdrop() }
            .navigationTitle("الشهادات")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("إغلاق") { dismiss() }
                        .font(T.sans(14, .bold))
                        .foregroundColor(T.accent)
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
