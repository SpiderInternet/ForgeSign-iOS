import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            AppsView()
                .tabItem {
                    Label("Apps", systemImage: "square.stack.3d.up.fill")
                }

            LibraryView()
                .tabItem {
                    Label("Sign", systemImage: "signature")
                }

            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle.fill")
                }
        }
    }
}

// MARK: - About View with Rights & Credits

struct AboutView: View {
    @Environment(\.forgeTheme) private var T

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        Image(systemName: "iphone.gen3")
                            .font(.system(size: 60))
                            .foregroundColor(T.accent)
                            .padding(.top, 30)

                        Text("Forge Sign")
                            .font(T.sans(24, .bold))
                            .foregroundColor(T.ink)

                        Text("Version 1.0.0")
                            .font(T.mono(12))
                            .foregroundColor(T.ink3)

                        // Rights & Developer Info
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Developer & Rights")
                                .font(T.sans(16, .bold))
                                .foregroundColor(T.accent)

                            HStack {
                                Text("Developed by:")
                                    .font(T.sans(14, .regular))
                                    .foregroundColor(T.ink2)
                                Spacer()
                                Text("Abdulbasit Khudhair")
                                    .font(T.sans(14, .bold))
                                    .foregroundColor(T.ink)
                            }

                            Divider()

                            Text("An iOS application signing and management tool customized for downloading, organizing, and preparing IPA files safely.")
                                .font(T.sans(13, .regular))
                                .foregroundColor(T.ink3)
                                .lineSpacing(4)
                        }
                        .padding(18)
                        .fGlass(cornerRadius: 16)
                        .padding(.horizontal, 16)

                        Text("© 2026 All Rights Reserved")
                            .font(T.sans(12, .regular))
                            .foregroundColor(T.ink3)
                            .padding(.bottom, 20)
                    }
                }
                .background { ForgeBackdrop() }
                .navigationTitle("About")
            }
        }
    }
}

// MARK: - Helper UI Activity View

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
