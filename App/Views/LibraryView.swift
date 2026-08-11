import SwiftUI

struct LibraryView: View {
    @Environment(\.forgeTheme) private var T
    
    @State private var showCertificatesSheet = false
    @State private var showImportIPASheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // Action Cards
                        VStack(spacing: 12) {
                            // Import IPA Card
                            Button(action: { showImportIPASheet = true }) {
                                HStack {
                                    Image(systemName: "doc.badge.plus")
                                        .font(.system(size: 24))
                                        .foregroundColor(T.accent)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("استيراد ملف IPA")
                                            .font(T.sans(16, .bold))
                                            .foregroundColor(T.ink)
                                        Text("اختر ملف IPA لتجهيزه للتوقيع")
                                            .font(T.sans(12, .regular))
                                            .foregroundColor(T.ink2)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.left")
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
                                        Text("إدارة الشهادات و provisioning")
                                            .font(T.sans(16, .bold))
                                            .foregroundColor(T.ink)
                                        Text("إضافة وإدارة ملفات .p12 و .mobileprovision")
                                            .font(T.sans(12, .regular))
                                            .foregroundColor(T.ink2)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.left")
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
                            Text("لا توجد ملفات IPA مستوردة")
                                .font(T.sans(15, .bold))
                                .foregroundColor(T.ink)
                            Text("ملفات الـ IPA التي تقوم باستيرادها ستظهر هنا لتوقيعها أو تثبيتها.")
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
                .navigationTitle("التوقيع والمكتبة")
                .sheet(isPresented: $showCertificatesSheet) {
                    CertificatesSheet()
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}
