import Foundation

struct AISEventFactory {

    static func commandEvent(
        rollbackCounter: UInt64,
        previousHash: String
    ) -> AISEvent {

        AISEvent(
            rollbackCounter: rollbackCounter,
            eventType: .command,
            trustState: .trusted,
            previousHash: previousHash
        )
    }

    static func bootEvent(
        rollbackCounter: UInt64,
        previousHash: String
    ) -> AISEvent {

        AISEvent(
            rollbackCounter: rollbackCounter,
            eventType: .boot,
            trustState: .trusted,
            previousHash: previousHash
        )
    }

    static func trustBreakEvent(
        rollbackCounter: UInt64,
        previousHash: String
    ) -> AISEvent {

        AISEvent(
            rollbackCounter: rollbackCounter,
            eventType: .trustBroken,
            trustState: .broken,
            previousHash: previousHash
        )
    }
}
