import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            AppsView()
                .tabItem {
                    Label("Apps", systemImage: "squares.below.rectangle")
                }
                .tag(0)

            LibraryView()
                .tabItem {
                    Label("Sign", systemImage: "signature")
                }
                .tag(1)

            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
                .tag(2)
        }
    }
}

// MARK: - About View (UrSign)

struct AboutView: View {
    @Environment(\.forgeTheme) private var T
    @Environment(\.openURL) private var openURL

    private let appName = "UrSign"
    private let appVersion = "1.0.0"
    private let developerName = "Abdulbasit Khudhair"
    
    private let telegramURL = "https://t.me/ipafilesfor"
    private let tiktokURL = "https://www.tiktok.com/@087.n?_r=1&_t=ZP-98myBkMQ7tX"

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // Header / App Logo & Name
                        VStack(spacing: 10) {
                            Image(systemName: "iphone.gen3")
                                .font(.system(size: 60))
                                .foregroundColor(T.accent)
                                .padding(.top, 20)

                            Text(appName)
                                .font(T.sans(26, .bold))
                                .foregroundColor(T.ink)

                            Text("Version \(appVersion)")
                                .font(T.mono(12))
                                .foregroundColor(T.ink3)
                        }

                        // Developer & Rights Info
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Developer & Rights")
                                .font(T.sans(16, .bold))
                                .foregroundColor(T.accent)

                            HStack {
                                Text("Developed by:")
                                    .font(T.sans(14, .regular))
                                    .foregroundColor(T.ink2)
                                Spacer()
                                Text(developerName)
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

                        // Connect Links
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Connect with Developer")
                                .font(T.sans(16, .bold))
                                .foregroundColor(T.ink)

                            HStack(spacing: 12) {
                                Button(action: {
                                    if let url = URL(string: telegramURL) { openURL(url) }
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

                                Button(action: {
                                    if let url = URL(string: tiktokURL) { openURL(url) }
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
