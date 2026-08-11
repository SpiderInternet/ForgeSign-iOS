import SwiftUI

@main
struct ForgeApp: App {
    @StateObject private var sourceStore = SourceStore()
    @StateObject private var repoStore = RepositoryStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sourceStore)
                .environmentObject(repoStore)
        }
    }
}
