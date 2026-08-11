import Foundation

@MainActor
class SourceStore: ObservableObject {
    @Published var apps: [FeedApp] = []
    @Published var isLoading = false

    private let defaultSourceURLs = [
        "https://repository.apptesters.org/altstore/apps.json",
        "https://ipa.cypwn.xyz/cypwn.json",
        "https://altstore.oatmealdome.me/apps.json"
    ]

    func fetchSources() async {
        isLoading = true
        defer { isLoading = false }

        var fetchedApps: [FeedApp] = []

        for urlString in defaultSourceURLs {
            guard let url = URL(string: urlString) else { continue }

            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { continue }

                let feed = try JSONDecoder().decode(SourceFeed.self, from: data)
                fetchedApps.append(contentsOf: feed.apps)
            } catch {
                print("Failed to load source: \(urlString) - Error: \(error)")
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
}
