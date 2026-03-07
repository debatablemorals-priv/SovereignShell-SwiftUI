import Foundation
import CryptoKit

struct AISEvent: Codable, Equatable {
    let rollbackCounter: UInt64
    let eventType: AISEventType
    let trustState: AISTrustState
    let previousHash: String
    let envelopeHash: String

    init(
        rollbackCounter: UInt64,
        eventType: AISEventType,
        trustState: AISTrustState,
        previousHash: String
    ) {
        self.rollbackCounter = rollbackCounter
        self.eventType = eventType
        self.trustState = trustState
        self.previousHash = previousHash
        self.envelopeHash = AISEvent.computeEnvelopeHash(
            rollbackCounter: rollbackCounter,
            eventType: eventType,
            trustState: trustState,
            previousHash: previousHash
        )
    }

    static func computeEnvelopeHash(
        rollbackCounter: UInt64,
        eventType: AISEventType,
        trustState: AISTrustState,
        previousHash: String
    ) -> String {
        let canonical = [
            String(rollbackCounter),
            eventType.rawValue,
            trustState.rawValue,
            previousHash
        ].joined(separator: "|")

        let digest = SHA256.hash(data: Data(canonical.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
