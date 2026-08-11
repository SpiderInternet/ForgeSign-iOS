import Foundation

@MainActor
class SourceStore: ObservableObject {
    @Published var apps: [FeedApp] = []
    @Published var sources: [URL] = [
        URL(string: "https://repository.apptesters.org/altstore/apps.json")!,
        URL(string: "https://ipa.cypwn.xyz/cypwn.json")!,
        URL(string: "https://altstore.oatmealdome.me/apps.json")!
    ]
    @Published var isLoading = false

    func fetchSources() async {
        isLoading = true
        defer { isLoading = false }

        var fetchedApps: [FeedApp] = []

        for url in sources {
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { continue }

                let feed = try JSONDecoder().decode(SourceFeed.self, from: data)
                fetchedApps.append(contentsOf: feed.apps)
            } catch {
                print("Failed to load source: \(url) - Error: \(error)")
            }
        }

        var uniqueApps: [FeedApp] = []
        for app in fetchedApps {
            if !uniqueApps.contains(where: { $0.bundleIdentifier == app.bundleIdentifier }) {
                uniqueApps.append(app)
            }
        }

        self.apps = uniqueApps
    }

    func addSource(_ url: URL) {
        guard !sources.contains(url) else { return }
        sources.append(url)
        Task { await fetchSources() }
    }

    func removeSource(at offsets: IndexSet) {
        sources.remove(atOffsets: offsets)
        Task { await fetchSources() }
    }
}
