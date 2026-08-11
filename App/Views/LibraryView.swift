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
                        
                        // Header Action Cards
                        VStack(spacing: 12) {
                            // Import IPA Card
                            Button(action: { showImportIPASheet = true }) {
                                HStack {
                                    Image(systemName: "doc.badge.plus")
                                        .font(.system(size: 24))
                                        .foregroundColor(T.accent)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Import IPA File")
                                            .font(T.sans(16, .bold))
                                            .foregroundColor(T.ink)
                                        Text("Select and prepare IPA for signing")
                                            .font(T.sans(12, .regular))
                                            .foregroundColor(T.ink2)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
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
                                        Text("Certificates & Provisioning")
                                            .font(T.sans(16, .bold))
                                            .foregroundColor(T.ink)
                                        Text("Add and manage .p12 & .mobileprovision")
                                            .font(T.sans(12, .regular))
                                            .foregroundColor(T.ink2)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
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
                            Text("No Signed or Imported IPAs")
                                .font(T.sans(15, .bold))
                                .foregroundColor(T.ink)
                            Text("Imported IPA files will appear here ready to sign or install.")
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
                .navigationTitle("Sign & Library")
                .sheet(isPresented: $showCertificatesSheet) {
                    CertificatesSheet()
                }
            }
        }
    }
}
