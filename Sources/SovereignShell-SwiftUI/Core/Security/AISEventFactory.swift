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

    static func handoffAttestedEvent(
        rollbackCounter: UInt64,
        previousHash: String,
        handoffClass: AISHandoffClass
    ) -> AISEvent {

        AISEvent(
            rollbackCounter: rollbackCounter,
            eventType: .handoffAttested,
            trustState: .trusted,
            handoffClass: handoffClass,
            previousHash: previousHash
        )
    }

    static func handoffFailedEvent(
        rollbackCounter: UInt64,
        previousHash: String,
        handoffClass: AISHandoffClass
    ) -> AISEvent {

        AISEvent(
            rollbackCounter: rollbackCounter,
            eventType: .handoffFailed,
            trustState: .broken,
            handoffClass: handoffClass,
            previousHash: previousHash
        )
    }

    static func trustBrokenEvent(
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
