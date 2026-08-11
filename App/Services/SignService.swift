import Foundation
import UIKit

@MainActor
final class SignService {
    static let shared = SignService()

    /// Signs the IPA for a given app/version using the provided certificate/profile and then calls InstallController to install.
    /// - Parameters:
    ///   - app: FeedApp (any type from the feed)
    ///   - version: version object (Any) — we reflect to find a download URL
    ///   - cert: CertificateRecord? — selected certificate
    ///   - profile: ProfileRecord? — selected provisioning profile
    ///   - installController: controller that will start installation when signing is done
    func signAndInstall(app: Any, version: Any, cert: CertificateRecord?, profile: ProfileRecord?, installController: InstallController) async throws {
        // Validate inputs
        guard let cert = cert else {
            throw NSError(domain: "SignService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No signing certificate selected. Open Certificates and choose one."])
        }
        guard let profile = profile else {
            throw NSError(domain: "SignService", code: 2, userInfo: [NSLocalizedDescriptionKey: "No provisioning profile selected. Import a .mobileprovision first."])
        }

        // Extract download URL from version using reflection (look for any property named url / download / ipa)
        let dlURL = extractDownloadURL(from: version)
        guard let downloadURL = dlURL else {
            throw NSError(domain: "SignService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Could not find a download URL for this version."])
        }

        // Download IPA to temporary file
        let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent("forgesign", isDirectory: true)
        try? FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
        let ipaDest = tmpDir.appendingPathComponent("input.ipa")
        if FileManager.default.fileExists(atPath: ipaDest.path) { try? FileManager.default.removeItem(at: ipaDest) }

        let (data, resp) = try await URLSession.shared.data(from: downloadURL)
        guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
            throw NSError(domain: "SignService", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to download IPA."])
        }
        try data.write(to: ipaDest, options: .atomic)

        // Prepare paths
        let certPath = CertificateStore().fileURL(for: cert).path
        let provPath = ProfileStore().fileURL(for: profile).path

        // Output path
        let outPath = tmpDir.appendingPathComponent("signed.ipa").path

        // Temp folder
        let tempFolder = tmpDir.path

        // Buffers
        var msgBuf = [CChar](repeating: 0, count: 2048)
        var bundleBuf = [CChar](repeating: 0, count: 512)
        var versionBuf = [CChar](repeating: 0, count: 256)

        // Call native signing bridge and capture Int32 result
        let result: Int32 = ipaDest.path.withCString { ipaC in
            certPath.withCString { certC in
                let pwd = PasswordVault.password(for: cert.id) ?? ""
                return pwd.withCString { pwdC in
                    provPath.withCString { provC in
                        return outPath.withCString { outC in
                            return tempFolder.withCString { tempC in
                                // removeExtensions = 0, enableDocuments = 0
                                let r = forgesign_sign_ipa(ipaC, certC, pwdC, provC, nil, outC, tempC, 0, 0, &msgBuf, Int32(msgBuf.count), &bundleBuf, Int32(bundleBuf.count), &versionBuf, Int32(versionBuf.count))
                                return r
                            }
                        }
                    }
                }
            }
        }

        if result != 0 {
            let msgBytes = msgBuf.prefix { $0 != 0 }.map { UInt8(bitPattern: $0) }
            let message = String(decoding: msgBytes, as: UTF8.self)
            throw NSError(domain: "SignService", code: Int(result), userInfo: [NSLocalizedDescriptionKey: "Signing failed: \(message)"])
        }

        // On success, call installController on main thread
        let signedIPA = URL(fileURLWithPath: outPath)
        let bundleIdStr = String(decoding: bundleBuf.prefix { $0 != 0 }.map { UInt8(bitPattern: $0) }, as: UTF8.self)
        let versionStr = String(decoding: versionBuf.prefix { $0 != 0 }.map { UInt8(bitPattern: $0) }, as: UTF8.self)
        await MainActor.run {
            installController.install(ipa: signedIPA, bundleId: bundleIdStr.isEmpty ? (appBundleIdentifier(from: app) ?? "") : bundleIdStr, version: versionStr)
        }
    }

    // Try to find a URL in the reflected object
    private func extractDownloadURL(from obj: Any) -> URL? {
        let m = Mirror(reflecting: obj)
        for child in m.children {
            if let label = child.label?.lowercased() {
                if label.contains("url") || label.contains("download") || label.contains("ipa") {
                    if let s = child.value as? String, let u = URL(string: s) { return u }
                    if let u = child.value as? URL { return u }
                }
            }
        }
        // Fallback: scan for any String that looks like URL
        func probe(_ m: Mirror) -> URL? {
            for child in m.children {
                if let s = child.value as? String, (s.hasPrefix("http://") || s.hasPrefix("https://")) {
                    return URL(string: s)
                }
                let inner = Mirror(reflecting: child.value)
                if let found = probe(inner) { return found }
            }
            return nil
        }
        return probe(m)
    }

    private func appBundleIdentifier(from app: Any) -> String? {
        let m = Mirror(reflecting: app)
        for child in m.children {
            if child.label?.lowercased().contains("bundle") == true {
                if let s = child.value as? String { return s }
            }
        }
        return nil
    }
}
