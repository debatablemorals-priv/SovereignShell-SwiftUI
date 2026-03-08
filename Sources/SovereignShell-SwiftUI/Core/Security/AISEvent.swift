import Foundation
import CryptoKit

/// AISEvent represents a deterministic trust event recorded by AIS.
///
/// The peerBindingToken is required for all events but may be empty for
/// non-handoff events. Handoff events must supply a non-empty token.

struct AISEvent: Codable, Equatable {

    let rollbackCounter: UInt64
    let eventType: AISEventType
    let trustState: AISTrustState
    let handoffClass: AISHandoffClass
    let peerBindingToken: String
    let previousHash: String
    let envelopeHash: String

    init(
        rollbackCounter: UInt64,
        eventType: AISEventType,
        trustState: AISTrustState,
        handoffClass: AISHandoffClass = .none,
        peerBindingToken: String = "",
        previousHash: String
    ) {

        self.rollbackCounter = rollbackCounter
        self.eventType = eventType
        self.trustState = trustState
        self.handoffClass = handoffClass
        self.peerBindingToken = peerBindingToken
        self.previousHash = previousHash

        self.envelopeHash = AISEvent.computeEnvelopeHash(
            rollbackCounter: rollbackCounter,
            eventType: eventType,
            trustState: trustState,
            handoffClass: handoffClass,
            peerBindingToken: peerBindingToken,
            previousHash: previousHash
        )
    }

    private static func computeEnvelopeHash(
        rollbackCounter: UInt64,
        eventType: AISEventType,
        trustState: AISTrustState,
        handoffClass: AISHandoffClass,
        peerBindingToken: String,
        previousHash: String
    ) -> String {

        let canonical = [
            String(rollbackCounter),
            eventType.rawValue,
            trustState.rawValue,
            handoffClass.rawValue,
            peerBindingToken,
            previousHash
        ].joined(separator: "|")

        let digest = SHA256.hash(data: Data(canonical.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
