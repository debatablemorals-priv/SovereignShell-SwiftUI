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
            peerBindingToken: "",
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
            peerBindingToken: "",
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
            peerBindingToken: "",
            previousHash: previousHash
        )
    }

    static func handoffStartEvent(
        rollbackCounter: UInt64,
        previousHash: String,
        handoffClass: AISHandoffClass,
        peerBindingToken: String
    ) -> AISEvent {

        AISEvent(
            rollbackCounter: rollbackCounter,
            eventType: .transferOut,
            trustState: .inTransit,
            handoffClass: handoffClass,
            peerBindingToken: peerBindingToken,
            previousHash: previousHash
        )
    }

    static func handoffAcceptedEvent(
        rollbackCounter: UInt64,
        previousHash: String,
        handoffClass: AISHandoffClass,
        peerBindingToken: String
    ) -> AISEvent {

        AISEvent(
            rollbackCounter: rollbackCounter,
            eventType: .transferIn,
            trustState: .trusted,
            handoffClass: handoffClass,
            peerBindingToken: peerBindingToken,
            previousHash: previousHash
        )
    }

    static func handoffFailedEvent(
        rollbackCounter: UInt64,
        previousHash: String,
        handoffClass: AISHandoffClass,
        peerBindingToken: String
    ) -> AISEvent {

        AISEvent(
            rollbackCounter: rollbackCounter,
            eventType: .trustBroken,
            trustState: .broken,
            handoffClass: handoffClass,
            peerBindingToken: peerBindingToken,
            previousHash: previousHash
        )
    }
}
