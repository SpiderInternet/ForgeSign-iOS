import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            AppsView()
                .tabItem {
                    Label("Apps", systemImage: "square.stack.3d.up.fill")
                }

            SigningView()
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

// MARK: - About View

struct AboutView: View {
    @Environment(\.forgeTheme) private var T

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        Image(systemName: "hammer.fill")
                            .font(.system(size: 60))
                            .foregroundColor(T.accent)
                            .padding(.top, 40)

                        Text("Forge Sign")
                            .font(T.sans(22, .bold))
                            .foregroundColor(T.ink)

                        Text("Version 1.0.0")
                            .font(T.mono(13))
                            .foregroundColor(T.ink3)

                        VStack(alignment: .leading, spacing: 12) {
                            Text("About Application")
                                .font(T.sans(16, .bold))
                                .foregroundColor(T.ink)

                            Text("An iOS application signing and repository catalog tool designed for easy IPA management and profile installation.")
                                .font(T.sans(14, .regular))
                                .foregroundColor(T.ink3)
                        }
                        .padding(16)
                        .fGlass(cornerRadius: 16)
                        .padding(.horizontal, 16)
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
