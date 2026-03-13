import Foundation

struct AISEventFactory {

    static func commandEvent(
        rollbackCounter: UInt64,
        previousHash: String
    ) -> AISEvent {
        AISEvent(
            rollbackCounter: rollbackCounter,
            timestamp: deterministicTimestamp(for: rollbackCounter),
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
            timestamp: deterministicTimestamp(for: rollbackCounter),
            eventType: .boot,
            trustState: .trusted,
            handoffClass: .none,
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
            timestamp: deterministicTimestamp(for: rollbackCounter),
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
            timestamp: deterministicTimestamp(for: rollbackCounter),
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
            timestamp: deterministicTimestamp(for: rollbackCounter),
            eventType: .trustBroken,
            trustState: .broken,
            handoffClass: .none,
            previousHash: previousHash
        )
    }

    private static func deterministicTimestamp(for rollbackCounter: UInt64) -> UInt64 {
        rollbackCounter
    }
}

// deterministic AIS event factory
