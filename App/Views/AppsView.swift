import SwiftUI

struct AppsView: View {
    @Environment(\.forgeTheme) private var T
    @EnvironmentObject private var store: SourceStore
    @AppStorage("appLanguage") private var appLanguage: String = "ar"

    @State private var selectedApp: FeedApp?
    @State private var showSourcesSettings = false

    var featuredApps: [FeedApp] {
        Array(store.apps.prefix(5))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        if store.isLoading && store.apps.isEmpty {
                            VStack(spacing: 12) {
                                ProgressView()
                                    .tint(T.accent)
                                Text(appLanguage == "ar" ? "جاري تحميل التطبيقات..." : "Loading Apps...")
                                    .font(T.sans(14, .regular))
                                    .foregroundColor(T.ink2)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 80)
                        } else if store.apps.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "square.stack.3d.up.slash")
                                    .font(.system(size: 48))
                                    .foregroundColor(T.ink3)
                                
                                Text(appLanguage == "ar" ? "لا توجد تطبيقات معروضة" : "No Apps Displayed")
                                    .font(T.sans(17, .bold))
                                    .foregroundColor(T.ink)
                                
                                Text(appLanguage == "ar" ? "يمكنك إضافة سورس جديد أو إدارة المصادر لعرض التطبيقات." : "Add a source to start viewing applications.")
                                    .font(T.sans(13, .regular))
                                    .foregroundColor(T.ink2)
                                    .multilineTextAlignment(.center)
                                
                                Button(action: { showSourcesSettings = true }) {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                        Text(appLanguage == "ar" ? "إدارة وتأكيد المصادر" : "Manage Sources")
                                    }
                                    .font(T.sans(14, .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(T.accent)
                                    .cornerRadius(12)
                                }
                            }
                            .padding(24)
                            .fGlass(cornerRadius: 18)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 40)
                        } else {
                            
                            // 1. Featured Top Slider (App Store Style)
                            if !featuredApps.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(featuredApps, id: \.bundleIdentifier) { app in
                                            Button(action: { selectedApp = app }) {
                                                VStack(alignment: .leading, spacing: 10) {
                                                    Text(appLanguage == "ar" ? "تطبيق مميز" : "FEATURED APP")
                                                        .font(T.sans(11, .bold))
                                                        .foregroundColor(T.accent)
                                                    
                                                    Text(app.title ?? "App")
                                                        .font(T.sans(18, .bold))
                                                        .foregroundColor(T.ink)
                                                        .lineLimit(1)
                                                    
                                                    Text(app.description ?? "")
                                                        .font(T.sans(13, .regular))
                                                        .foregroundColor(T.ink2)
                                                        .lineLimit(2)
                                                    
                                                    ZStack(alignment: .bottomLeading) {
                                                        RoundedRectangle(cornerRadius: 16)
                                                            .fill(T.accent.opacity(0.15))
                                                            .frame(height: 160)
                                                        
                                                        HStack {
                                                            AsyncImage(url: app.iconURL) { img in
                                                                img.resizable().scaledToFill()
                                                            } placeholder: {
                                                                Color.gray.opacity(0.3)
                                                            }
                                                            .frame(width: 50, height: 50)
                                                            .cornerRadius(12)

                                                            VStack(alignment: .leading, spacing: 2) {
                                                                Text(app.title ?? "")
                                                                    .font(T.sans(14, .bold))
                                                                    .foregroundColor(T.ink)
                                                                Text(app.developer ?? "")
                                                                    .font(T.sans(11, .regular))
                                                                    .foregroundColor(T.ink3)
                                                            }
                                                            Spacer()
                                                            Image(systemName: "arrow.down.circle.fill")
                                                                .font(.system(size: 24))
                                                                .foregroundColor(T.accent)
                                                        }
                                                        .padding(12)
                                                        .fGlass(cornerRadius: 14)
                                                        .padding(10)
                                                    }
                                                }
                                                .frame(width: 300)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }

                            // 2. Main App List Section
                            VStack(alignment: .leading, spacing: 14) {
                                Text(appLanguage == "ar" ? "تطبيقات لا تستغني عنها" : "Must-Have Apps")
                                    .font(T.sans(18, .bold))
                                    .foregroundColor(T.ink)
                                    .padding(.horizontal, 16)

                                LazyVStack(spacing: 12) {
                                    ForEach(store.apps, id: \.bundleIdentifier) { app in
                                        Button(action: { selectedApp = app }) {
                                            HStack(spacing: 14) {
                                                AsyncImage(url: app.iconURL) { img in
                                                    img.resizable().scaledToFill()
                                                } placeholder: {
                                                    Color.gray.opacity(0.3)
                                                }
                                                .frame(width: 56, height: 56)
                                                .cornerRadius(12)

                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(app.title ?? "App")
                                                        .font(T.sans(15, .bold))
                                                        .foregroundColor(T.ink)
                                                        .lineLimit(1)
                                                    Text(app.description ?? app.developer ?? "")
                                                        .font(T.sans(12, .regular))
                                                        .foregroundColor(T.ink2)
                                                        .lineLimit(1)
                                                }

                                                Spacer()

                                                Image(systemName: "icloud.and.arrow.down")
                                                    .font(.system(size: 20))
                                                    .foregroundColor(T.accent)
                                            }
                                            .padding(12)
                                            .fGlass(cornerRadius: 14)
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                    .padding(.vertical, 16)
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
    }
}
