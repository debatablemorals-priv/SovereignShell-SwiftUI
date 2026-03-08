import Foundation
import CryptoKit

extension LedgerEntry {
    init(event: AISEvent) {
        self.init(
            rollbackCounter: event.rollbackCounter,
            requestHash: Self.hash(event.eventType.rawValue),
            responseHash: Self.hash(
                event.trustState.rawValue + "|" + event.handoffClass.rawValue
            ),
            previousHash: event.previousHash
        )
    }

    func asAISEvent() -> AISEvent {
        AISEvent(
            rollbackCounter: rollbackCounter,
            timestamp: UInt64(max(0, Int64(timestamp.timeIntervalSince1970))),
            eventType: AISEventType.command,
            trustState: AISTrustState.trusted,
            handoffClass: AISHandoffClass.none,
            previousHash: previousHash,
            envelopeHash: envelopeHash
        )
    }

    private static func hash(_ value: String) -> String {
        let data = Data(value.utf8)
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
