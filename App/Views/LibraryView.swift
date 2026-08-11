import SwiftUI

struct LibraryView: View {
    @Environment(\.forgeTheme) private var T
    @AppStorage("appLanguage") private var appLanguage: String = "ar"
    
    @State private var showCertificatesSheet = false
    @State private var showFileImporter = false

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // Action Cards
                        VStack(spacing: 12) {
                            // Import IPA Card
                            Button(action: { showFileImporter = true }) {
                                HStack {
                                    Image(systemName: "doc.badge.plus")
                                        .font(.system(size: 24))
                                        .foregroundColor(T.accent)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(appLanguage == "ar" ? "استيراد ملف IPA" : "Import IPA File")
                                            .font(T.sans(16, .bold))
                                            .foregroundColor(T.ink)
                                        Text(appLanguage == "ar" ? "اختر ملف IPA لتجهيزه للتوقيع" : "Select IPA file for signing")
                                            .font(T.sans(12, .regular))
                                            .foregroundColor(T.ink2)
                                    }
                                    Spacer()
                                    Image(systemName: appLanguage == "ar" ? "chevron.left" : "chevron.right")
                                        .foregroundColor(T.ink3)
                                }
                                .padding(16)
                                .fGlass(cornerRadius: 16)
                            }

                            // Manage Certificates Card
                            Button(action: { showCertificatesSheet = true }) {
                                HStack {
                                    Image(systemName: "key.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.orange)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(appLanguage == "ar" ? "إدارة الشهادات و provisioning" : "Certificates & Provisioning")
                                            .font(T.sans(16, .bold))
                                            .foregroundColor(T.ink)
                                        Text(appLanguage == "ar" ? "إضافة وإدارة ملفات .p12 و .mobileprovision" : "Add .p12 & .mobileprovision")
                                            .font(T.sans(12, .regular))
                                            .foregroundColor(T.ink2)
                                    }
                                    Spacer()
                                    Image(systemName: appLanguage == "ar" ? "chevron.left" : "chevron.right")
                                        .foregroundColor(T.ink3)
                                }
                                .padding(16)
                                .fGlass(cornerRadius: 16)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 10)

                        // Empty State / Local IPAs List
                        VStack(spacing: 12) {
                            Image(systemName: "tray.fill")
                                .font(.system(size: 40))
                                .foregroundColor(T.ink3)
                            Text(appLanguage == "ar" ? "لا توجد ملفات IPA مستوردة" : "No Imported IPAs")
                                .font(T.sans(15, .bold))
                                .foregroundColor(T.ink)
                            Text(appLanguage == "ar" ? "ملفات الـ IPA التي تقوم باستيرادها ستظهر هنا لتوقيعها أو تثبيتها." : "Imported IPA files will appear here ready to sign or install.")
                                .font(T.sans(12, .regular))
                                .foregroundColor(T.ink2)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(24)
                        .fGlass(cornerRadius: 16)
                        .padding(.horizontal, 16)
                    }
                }
                .background { ForgeBackdrop() }
                .navigationTitle(appLanguage == "ar" ? "التوقيع والمكتبة" : "Sign & Library")
                .fileImporter(
                    isPresented: $showFileImporter,
                    allowedContentTypes: [.item],
                    allowsMultipleSelection: false
                ) { result in
                    switch result {
                    case .success(let urls):
                        guard let selectedURL = urls.first else { return }
                        print("Selected IPA: \(selectedURL)")
                    case .failure(let error):
                        print("File import error: \(error.localizedDescription)")
                    }
                }
                .sheet(isPresented: $showCertificatesSheet) {
                    CertificatesSheet()
                }
            }
        }
        .environment(\.layoutDirection, appLanguage == "ar" ? .rightToLeft : .leftToRight)
    }
}
