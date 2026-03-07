import Foundation

extension AISExecutionLedger {

    func appendEvent(_ event: AISEvent) throws {

        let entry = LedgerEntry(
            rollbackCounter: event.rollbackCounter,
            requestHash: String(repeating: "0", count: 64),
            responseHash: String(repeating: "0", count: 64),
            previousHash: event.previousHash
        )

        try append(entry)
    }
}
