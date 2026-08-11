import SwiftUI
import Combine

class SourceStore: ObservableObject {
    @Published var apps: [FeedApp] = []
    @Published var isLoading: Bool = false
    @Published var sources: [String] = []

    // السورس الوحيد المعتمد في التطبيق
    private let defaultSource = "https://repository.apptesters.org"

    init() {
        setupSingleSource()
        fetchApps()
    }

    /// تعيين السورس الوحيد ومسح أي سورسات قديمة مخزنة
    func setupSingleSource() {
        self.sources = [defaultSource]
        UserDefaults.standard.set(self.sources, forKey: "user_sources")
    }

    /// جلب التطبيقات من السورس المعتمد
    func fetchApps() {
        guard let url = URL(string: defaultSource) else { return }
        
        DispatchQueue.main.async {
            self.isLoading = true
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
            }
            
            guard let data = data, error == nil else {
                print("Error fetching source: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                // فك تشفير بيانات السورس والجلب
                let decodedResponse = try JSONDecoder().decode(SourceFeed.self, from: data)
                DispatchQueue.main.async {
                    self?.apps = decodedResponse.apps ?? []
                }
            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }.resume()
    }
}

// نموذج فك تشفير JSON للسورس
struct SourceFeed: Codable {
    let name: String?
    let identifier: String?
    let apps: [FeedApp]?
}
