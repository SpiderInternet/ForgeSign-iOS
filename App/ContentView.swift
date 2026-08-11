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

// MARK: - About View with Direct Social Links

struct AboutView: View {
    @Environment(\.forgeTheme) private var T
    @Environment(\.openURL) private var openURL

    private let telegramURL = "https://t.me/ipafilesfor"
    private let tiktokURL = "https://www.tiktok.com/@087.n?_r=1&_t=ZP-98myBkMQ7tX"

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

                        // 1. Rights & Developer Info
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

                        // 2. Direct Social Links
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Connect with Developer")
                                .font(T.sans(16, .bold))
                                .foregroundColor(T.ink)

                            HStack(spacing: 12) {
                                // Telegram Button
                                Button(action: {
                                    if let url = URL(string: telegramURL) {
                                        openURL(url)
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "paperplane.fill")
                                        Text("Telegram")
                                            .font(T.sans(14, .bold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.blue)
                                    .cornerRadius(12)
                                }

                                // TikTok Button
                                Button(action: {
                                    if let url = URL(string: tiktokURL) {
                                        openURL(url)
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "play.circle.fill")
                                        Text("TikTok")
                                            .font(T.sans(14, .bold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.black)
                                    .cornerRadius(12)
                                }
                            }
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
