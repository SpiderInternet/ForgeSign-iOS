import Foundation

// MARK: - Source Feed Structure

struct SourceFeed: Codable {
    let name: String?
    let identifier: String?
    let apps: [FeedApp]

    enum CodingKeys: String, CodingKey {
        case name
        case identifier
        case apps
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try? container.decode(String.self, forKey: .name)
        self.identifier = try? container.decode(String.self, forKey: .identifier)
        
        if let appsList = try? container.decode([FeedApp].self, forKey: .apps) {
            self.apps = appsList
        } else {
            self.apps = []
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(identifier, forKey: .identifier)
        try container.encode(apps, forKey: .apps)
    }
}

// MARK: - Feed App Model

struct FeedApp: Codable, Identifiable {
    var id: String { bundleIdentifier }

    let bundleIdentifier: String
    let title: String?
    let developer: String?
    let description: String?
    let iconURL: URL?
    let bannerURL: URL?
    let imageURL: URL?
    let versions: [FeedVersion]

    enum CodingKeys: String, CodingKey {
        case bundleIdentifier
        case bundleID
        case name
        case title
        case developer = "developerName"
        case description = "localizedDescription"
        case iconURL
        case bannerURL
        case banner
        case imageURL
        case image
        case versions
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let bId = try? container.decode(String.self, forKey: .bundleIdentifier) {
            self.bundleIdentifier = bId
        } else if let bId = try? container.decode(String.self, forKey: .bundleID) {
            self.bundleIdentifier = bId
        } else {
            self.bundleIdentifier = UUID().uuidString
        }

        self.title = (try? container.decode(String.self, forKey: .name)) ?? (try? container.decode(String.self, forKey: .title))
        self.developer = try? container.decode(String.self, forKey: .developer)
        self.description = try? container.decode(String.self, forKey: .description)

        // icon URL
        if let iconString = try? container.decode(String.self, forKey: .iconURL) {
            self.iconURL = URL(string: iconString)
        } else {
            self.iconURL = nil
        }

        // banner / image priority: try multiple common keys
        var bannerString: String? = nil
        if let s = try? container.decode(String.self, forKey: .bannerURL) { bannerString = s }
        if bannerString == nil, let s = try? container.decode(String.self, forKey: .banner) { bannerString = s }
        if bannerString == nil, let s = try? container.decode(String.self, forKey: .imageURL) { bannerString = s }
        if bannerString == nil, let s = try? container.decode(String.self, forKey: .image) { bannerString = s }

        if let b = bannerString, !b.isEmpty {
            self.bannerURL = URL(string: b)
        } else {
            self.bannerURL = nil
        }

        // imageURL (distinct) fallback — try imageURL then image
        if let imgString = try? container.decode(String.self, forKey: .imageURL) {
            self.imageURL = URL(string: imgString)
        } else if let imgString = try? container.decode(String.self, forKey: .image) {
            self.imageURL = URL(string: imgString)
        } else {
            self.imageURL = nil
        }

        if let versionsList = try? container.decode([FeedVersion].self, forKey: .versions) {
            self.versions = versionsList
        } else {
            self.versions = []
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(bundleIdentifier, forKey: .bundleIdentifier)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(developer, forKey: .developer)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(iconURL?.absoluteString, forKey: .iconURL)
        try container.encodeIfPresent(bannerURL?.absoluteString, forKey: .bannerURL)
        try container.encodeIfPresent(imageURL?.absoluteString, forKey: .imageURL)
        try container.encode(versions, forKey: .versions)
    }
}

// MARK: - Feed Version Model

struct FeedVersion: Codable {
    let version: String
    let downloadURL: URL?
    let size: Int64?

    enum CodingKeys: String, CodingKey {
        case version
        case downloadURL
        case size
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.version = (try? container.decode(String.self, forKey: .version)) ?? "1.0"

        if let urlString = try? container.decode(String.self, forKey: .downloadURL) {
            self.downloadURL = URL(string: urlString)
        } else {
            self.downloadURL = nil
        }

        self.size = try? container.decode(Int64.self, forKey: .size)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(version, forKey: .version)
        try container.encodeIfPresent(downloadURL?.absoluteString, forKey: .downloadURL)
        try container.encodeIfPresent(size, forKey: .size)
    }
}
