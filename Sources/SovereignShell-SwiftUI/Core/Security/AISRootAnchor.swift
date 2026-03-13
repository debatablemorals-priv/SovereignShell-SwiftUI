import Foundation
import CryptoKit

struct AISRootAnchor {
    let data: Data

    static func loadOrCreate(at fileURL: URL, fileManager: FileManager = .default) throws -> AISRootAnchor {
        let normalizedURL = fileURL.standardizedFileURL

        if fileManager.fileExists(atPath: normalizedURL.path) {
            let data = try Data(contentsOf: normalizedURL)
            guard !data.isEmpty else {
                throw LedgerError.corruptedLedger
            }
            return AISRootAnchor(data: data)
        }

        let anchorData = Data((0..<32).map { _ in UInt8.random(in: 0...255) })

        let directoryURL = normalizedURL.deletingLastPathComponent()
        if !fileManager.fileExists(atPath: directoryURL.path) {
            try fileManager.createDirectory(
                at: directoryURL,
                withIntermediateDirectories: true
            )
        }

        try anchorData.write(to: normalizedURL, options: .atomic)

        #if os(iOS)
        try fileManager.setAttributes(
            [.protectionKey: FileProtectionType.complete],
            ofItemAtPath: normalizedURL.path
        )
        #endif

        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        var mutableURL = normalizedURL
        try mutableURL.setResourceValues(values)

        return AISRootAnchor(data: anchorData)
    }

    func childDigest(
        measurement: AISRuntimeMeasurement,
        policyVersion: AISPolicyVersion,
        ledgerDomain: AISLedgerDomain
    ) -> String {
        var hasher = SHA256()

        hasher.update(data: data)
        hasher.update(data: Data(measurement.sandboxMeasurement.utf8))
        hasher.update(data: Data(measurement.terminalMeasurement.utf8))
        hasher.update(data: Data(policyVersion.rawValue.utf8))
        hasher.update(data: Data(ledgerDomain.rawValue.utf8))

        let digest = hasher.finalize()
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
