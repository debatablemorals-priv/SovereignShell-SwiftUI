import Foundation
import CryptoKit

/// AISEvent represents a minimal trust attestation recorded by AIS.
/// AIS acts as a deterministic notary for trust continuity.

struct AISEvent: Codable, Equatable {

    let rollbackCounter: UInt64
    let timestamp: UInt64
    let eventType: AISEventType
    let trustState: AISTrustState
    let handoffClass: AISHandoffClass
    let previousHash: String
    let envelopeHash: String

    init(
        rollbackCounter: UInt64,
        timestamp: UInt64 = UInt64(Date().timeIntervalSince1970),
        eventType: AISEventType,
        trustState: AISTrustState,
        handoffClass: AISHandoffClass = .none,
        previousHash: String
    ) {

        self.rollbackCounter = rollbackCounter
        self.timestamp = timestamp
        self.eventType = eventType
        self.trustState = trustState
        self.handoffClass = handoffClass
        self.previousHash = previousHash

        self.envelopeHash = AISEvent.computeEnvelopeHash(
            rollbackCounter: rollbackCounter,
            timestamp: timestamp,
            eventType: eventType,
            trustState: trustState,
            handoffClass: handoffClass,
            previousHash: previousHash
        )
    }

    private static func computeEnvelopeHash(
        rollbackCounter: UInt64,
        timestamp: UInt64,
        eventType: AISEventType,
        trustState: AISTrustState,
        handoffClass: AISHandoffClass,
        previousHash: String
    ) -> String {

        let canonical = [
            String(rollbackCounter),
            String(timestamp),
            eventType.rawValue,
            trustState.rawValue,
            handoffClass.rawValue,
            previousHash
        ].joined(separator: "|")

        let digest = SHA256.hash(data: Data(canonical.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
