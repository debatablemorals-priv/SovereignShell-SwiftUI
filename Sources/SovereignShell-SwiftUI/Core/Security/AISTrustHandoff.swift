import Foundation

/// AISTrustHandoff records minimal notarial trust-boundary events.
///
/// AIS does not derive identity, endpoint context, or peer metadata.
/// It only records that a valid handoff was attested or that a handoff failed.

struct AISTrustHandoff {

    enum Result {
        case attested
        case failed
    }

    static func record(
        result: Result,
        handoffClass: AISHandoffClass,
        ledger: AISExecutionLedger
    ) throws {
        let rollback = ledger.currentRollbackCounter() + 1
        let previousHash = try ledger.currentLedgerPreviousHash()

        let event: AISEvent

        switch result {
        case .attested:
            event = AISEventFactory.handoffAttestedEvent(
                rollbackCounter: rollback,
                previousHash: previousHash,
                handoffClass: handoffClass
            )

        case .failed:
            event = AISEventFactory.handoffFailedEvent(
                rollbackCounter: rollback,
                previousHash: previousHash,
                handoffClass: handoffClass
            )
        }

        try ledger.append(event: event)
    }
}
