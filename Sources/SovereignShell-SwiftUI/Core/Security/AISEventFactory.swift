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
            handoffClass: .none,
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
            handoffClass: .none,
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
            handoffClass: .none,
            previousHash: previousHash
        )
    }

    static func handoffEvent(
        rollbackCounter: UInt64,
        previousHash: String,
        handoffClass: AISHandoffClass
    ) -> AISEvent {
        AISEvent(
            rollbackCounter: rollbackCounter,
            eventType: .transferOut,
            trustState: .inTransit,
            handoffClass: handoffClass,
            previousHash: previousHash
        )
    }
}
