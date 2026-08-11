import SwiftUI

struct ContentView: View {
    @AppStorage("appLanguage") private var appLanguage: String = "ar"
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            AppsView()
                .tabItem {
                    Label(appLanguage == "ar" ? "التطبيقات" : "Apps", systemImage: "squares.below.rectangle")
                }
                .tag(0)

            LibraryView()
                .tabItem {
                    Label(appLanguage == "ar" ? "التوقيع" : "Sign", systemImage: "signature")
                }
                .tag(1)

            AboutView()
                .tabItem {
                    Label(appLanguage == "ar" ? "حول التطبيق" : "About", systemImage: "info.circle")
                }
                .tag(2)
        }
        .environment(\.layoutDirection, appLanguage == "ar" ? .rightToLeft : .leftToRight)
    }
}

// MARK: - About View (UrSign)

struct AboutView: View {
    @Environment(\.forgeTheme) private var T
    @Environment(\.openURL) private var openURL
    @AppStorage("appLanguage") private var appLanguage: String = "ar"

    private let appName = "UrSign"
    private let appVersion = "1.0.0"
    
    // متغير يتغير حسب لغة التطبيق
    private var developerName: String {
        appLanguage == "ar" ? "عبدالباسط خضير" : "Abdulbasit Khudhair"
    }
    
    private let telegramURL = "https://t.me/ipafilesfor"
    private let tiktokURL = "https://www.tiktok.com/@087.n?_r=1&_t=ZP-98myBkMQ7tX"

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // App Logo & Header
                        VStack(spacing: 10) {
                            Image(systemName: "iphone.gen3")
                                .font(.system(size: 60))
                                .foregroundColor(T.accent)
                                .padding(.top, 20)

                            Text(appName)
                                .font(T.sans(26, .bold))
                                .foregroundColor(T.ink)

                            Text(appLanguage == "ar" ? "الإصدار \(appVersion)" : "Version \(appVersion)")
                                .font(T.mono(12))
                                .foregroundColor(T.ink3)
                        }

                        // Language Switcher Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text(appLanguage == "ar" ? "لغة التطبيق" : "App Language")
                                .font(T.sans(16, .bold))
                                .foregroundColor(T.ink)

                            Picker("Language", selection: $appLanguage) {
                                Text("العربية").tag("ar")
                                Text("English").tag("en")
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(18)
                        .fGlass(cornerRadius: 16)
                        .padding(.horizontal, 16)

                        // Developer Info
                        VStack(alignment: .leading, spacing: 14) {
                            Text(appLanguage == "ar" ? "المطور والحقوق" : "Developer & Rights")
                                .font(T.sans(16, .bold))
                                .foregroundColor(T.accent)

                            HStack {
                                Text(appLanguage == "ar" ? "تطوير:" : "Developed by:")
                                    .font(T.sans(14, .regular))
                                    .foregroundColor(T.ink2)
                                Spacer()
                                Text(developerName)
                                    .font(T.sans(14, .bold))
                                    .foregroundColor(T.ink)
                            }

                            Divider()

                            Text(appLanguage == "ar" 
                                 ? "أداة متخصصة لتوقيع وإدارة تطبيقات iOS، مخصصة لتنزيل وتنظيم وتجهيز ملفات IPA بأمان."
                                 : "An iOS application signing and management tool customized for downloading, organizing, and preparing IPA files safely.")
                                .font(T.sans(13, .regular))
                                .foregroundColor(T.ink3)
                                .lineSpacing(4)
                        }
                        .padding(18)
                        .fGlass(cornerRadius: 16)
                        .padding(.horizontal, 16)

                        // Connect Links
                        VStack(alignment: .leading, spacing: 12) {
                            Text(appLanguage == "ar" ? "تواصل مع المطور" : "Connect with Developer")
                                .font(T.sans(16, .bold))
                                .foregroundColor(T.ink)

                            HStack(spacing: 12) {
                                Button(action: {
                                    if let url = URL(string: telegramURL) { openURL(url) }
                                }) {
                                    HStack {
                                        Image(systemName: "paperplane.fill")
                                        Text(appLanguage == "ar" ? "تليجرام" : "Telegram")
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
                                        Text(appLanguage == "ar" ? "تيك توك" : "TikTok")
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

                        Text(appLanguage == "ar" ? "© 2026 جميع الحقوق محفوظة" : "© 2026 All Rights Reserved")
                            .font(T.sans(12, .regular))
                            .foregroundColor(T.ink3)
                            .padding(.bottom, 20)
                    }
                }
                .background { ForgeBackdrop() }
                .navigationTitle(appLanguage == "ar" ? "حول التطبيق" : "About")
            }
        }
        .environment(\.layoutDirection, appLanguage == "ar" ? .rightToLeft : .leftToRight)
    }
}
