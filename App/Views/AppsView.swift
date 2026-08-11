import SwiftUI

struct AppsView: View {
    @Environment(\.forgeTheme) private var T
    @StateObject private var store = SourceStore.shared
    @AppStorage("appLanguage") private var appLanguage: String = "ar"

    @State private var searchText = ""
    @State private var selectedApp: FeedApp?
    @State private var showSourcesSettings = false

    var filteredApps: [FeedApp] {
        let allApps = store.sources.flatMap { $0.apps }
        if searchText.isEmpty {
            return allApps
        } else {
            return allApps.filter { app in
                app.name.localizedCaseInsensitiveContains(searchText) ||
                (app.localizedDescription?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 16) {
                        // Search Bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(T.ink3)
                            TextField(appLanguage == "ar" ? "بحث عن تطبيقات..." : "Search apps...", text: $searchText)
                                .font(T.sans(14, .regular))
                                .foregroundColor(T.ink)
                            if !searchText.isEmpty {
                                Button(action: { searchText = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(T.ink3)
                                }
                            }
                        }
                        .padding(12)
                        .fGlass(cornerRadius: 12)
                        .padding(.horizontal, 16)

                        if store.isLoading && filteredApps.isEmpty {
                            VStack(spacing: 12) {
                                ProgressView()
                                    .tint(T.accent)
                                Text(appLanguage == "ar" ? "جاري جلب التطبيقات..." : "Fetching applications...")
                                    .font(T.sans(14, .regular))
                                    .foregroundColor(T.ink2)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                        } else if filteredApps.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "squares.below.rectangle")
                                    .font(.system(size: 44))
                                    .foregroundColor(T.ink3)
                                Text(appLanguage == "ar" ? "لا توجد تطبيقات" : "No Apps Found")
                                    .font(T.sans(16, .bold))
                                    .foregroundColor(T.ink)
                                Text(appLanguage == "ar" ? "أضف مصادر من الإعدادات لعرض التطبيقات." : "Add sources from Settings to browse apps.")
                                    .font(T.sans(13, .regular))
                                    .foregroundColor(T.ink2)
                                    .multilineTextAlignment(.center)
                                
                                Button(action: { showSourcesSettings = true }) {
                                    Text(appLanguage == "ar" ? "إدارة المصادر" : "Manage Sources")
                                        .font(T.sans(14, .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(T.accent)
                                        .cornerRadius(10)
                                }
                                .padding(.top, 8)
                            }
                            .padding(24)
                            .fGlass(cornerRadius: 16)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 40)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredApps, id: \.bundleIdentifier) { app in
                                    AppCardView(app: app, onOpen: {
                                        selectedApp = app
                                    })
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.vertical, 12)
                }
                .background { ForgeBackdrop() }
                .navigationTitle(appLanguage == "ar" ? "التطبيقات" : "Apps")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showSourcesSettings = true }) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(T.accent)
                        }
                    }
                }
                .sheet(item: $selectedApp) { app in
                    AppDetailSheet(app: app, onInstall: { _ in })
                }
                .sheet(isPresented: $showSourcesSettings) {
                    SourcesSettingsView()
                }
            }
        }
        .environment(\.layoutDirection, appLanguage == "ar" ? .rightToLeft : .leftToRight)
        .task {
            if store.sources.isEmpty {
                await store.fetchAllSources()
            }
        }
    }
}
