import SwiftUI

@main
struct ForgeSignMobileApp: App {
    @StateObject private var sourceStore = SourceStore()
    @StateObject private var certStore = CertificateStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sourceStore)
                .environmentObject(certStore)
        }
    }
}
