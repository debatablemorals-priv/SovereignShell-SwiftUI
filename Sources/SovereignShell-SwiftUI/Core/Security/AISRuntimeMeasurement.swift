import Foundation
import CryptoKit

struct AISRuntimeMeasurement: Codable, Equatable {
    let sandboxMeasurement: String
    let terminalMeasurement: String

    init(
        sandboxMeasurement: String,
        terminalMeasurement: String
    ) {
        self.sandboxMeasurement = sandboxMeasurement
        self.terminalMeasurement = terminalMeasurement
    }

    init(
        sandboxComponents: [String],
        terminalComponents: [String]
    ) {
        self.sandboxMeasurement = Self.digest(for: sandboxComponents)
        self.terminalMeasurement = Self.digest(for: terminalComponents)
    }

    private static func digest(for components: [String]) -> String {
        let canonical = components.joined(separator: "|")
        let digest = SHA256.hash(data: Data(canonical.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
