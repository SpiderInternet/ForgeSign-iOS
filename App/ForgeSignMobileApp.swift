import SwiftUI

@main
struct ForgeSignMobileApp: App {
    @StateObject private var sourceStore = SourceStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sourceStore)
        }
    }
}
