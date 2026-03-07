import Foundation

extension LedgerEntry {
    func asAISEvent() -> AISEvent {
        AISEvent(
            rollbackCounter: rollbackCounter,
            eventType: .command,
            trustState: .trusted,
            previousHash: previousHash
        )
    }
}
