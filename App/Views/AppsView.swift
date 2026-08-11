import SwiftUI

struct AppsView: View {
    @Environment(\.forgeTheme) private var T
    @StateObject private var store = SourceStore.shared

    @State private var searchText = ""
    @State private var selectedApp: AppModel?
    @State private var showSourcesSettings = false

    var filteredApps: [AppModel] {
        if searchText.isEmpty {
            return store.allApps
        } else {
            return store.allApps.filter { app in
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
                            TextField("بحث عن تطبيقات...", text: $searchText)
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

                        if store.isLoading && store.allApps.isEmpty {
                            VStack(spacing: 12) {
                                ProgressView()
                                    .tint(T.accent)
                                Text("جاري جلب التطبيقات...")
                                    .font(T.sans(14, .regular))
                                    .foregroundColor(T.ink2)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                        } else if store.allApps.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "squares.below.rectangle")
                                    .font(.system(size: 44))
                                    .foregroundColor(T.ink3)
                                Text("لا توجد تطبيقات")
                                    .font(T.sans(16, .bold))
                                    .foregroundColor(T.ink)
                                Text("قم بإضافة مصادر (Sources) من الإعدادات لاستعراض التطبيقات.")
                                    .font(T.sans(13, .regular))
                                    .foregroundColor(T.ink2)
                                    .multilineTextAlignment(.center)
                                
                                Button(action: { showSourcesSettings = true }) {
                                    Text("إدارة المصادر")
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
                                ForEach(filteredApps) { app in
                                    AppCardView(app: app)
                                        .onTapGesture {
                                            selectedApp = app
                                        }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.vertical, 12)
                }
                .background { ForgeBackdrop() }
                .navigationTitle("التطبيقات")
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
                    AppDetailSheet(app: app)
                }
                .sheet(isPresented: $showSourcesSettings) {
                    SourcesSettingsView()
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
        .task {
            if store.allApps.isEmpty {
                await store.fetchAllSources()
            }
        }
    }
}
