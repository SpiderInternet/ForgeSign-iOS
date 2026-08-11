import SwiftUI

struct CertificatesSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.forgeTheme) private var T
    @AppStorage("appLanguage") private var appLanguage: String = "ar"

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 16) {
                        VStack(spacing: 12) {
                            Image(systemName: "key.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.orange)
                            Text(appLanguage == "ar" ? "إدارة الشهادات" : "Manage Certificates")
                                .font(T.sans(18, .bold))
                                .foregroundColor(T.ink)
                            Text(appLanguage == "ar" ? "قم بإضافة شهادة (.p12) وملف التعريف (.mobileprovision) لبدء التوقيع." : "Add a .p12 certificate and .mobileprovision profile to start signing.")
                                .font(T.sans(13, .regular))
                                .foregroundColor(T.ink2)
                                .multilineTextAlignment(.center)
                        }
                        .padding(20)
                        .fGlass(cornerRadius: 16)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    }
                }
                .background { ForgeBackdrop() }
                .navigationTitle(appLanguage == "ar" ? "الشهادات" : "Certificates")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(appLanguage == "ar" ? "إغلاق" : "Close") {
                            dismiss()
                        }
                        .foregroundColor(T.accent)
                    }
                }
            }
        }
        .environment(\.layoutDirection, appLanguage == "ar" ? .rightToLeft : .leftToRight)
    }
}
