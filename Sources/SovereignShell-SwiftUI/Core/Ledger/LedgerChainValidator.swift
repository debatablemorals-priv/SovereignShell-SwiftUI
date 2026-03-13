import Foundation

enum LedgerChainValidator {
    static func validate(_ entries: [LedgerEntry]) throws {
        guard !entries.isEmpty else {
            throw LedgerError.invalidGenesis
        }

        let genesis = entries[0]

        guard genesis.previousHash == String(repeating: "0", count: 64) else {
            throw LedgerError.invalidGenesis
        }

        guard genesis.envelopeHash == recomputeEnvelopeHash(for: genesis) else {
            throw LedgerError.corruptedLedger
        }

        if entries.count == 1 {
            return
        }

        var previous = genesis
        for current in entries.dropFirst() {
            guard current.previousHash == previous.envelopeHash else {
                throw LedgerError.corruptedLedger
            }

            guard current.rollbackCounter > previous.rollbackCounter else {
                throw LedgerError.rollbackViolation
            }

            guard current.envelopeHash == recomputeEnvelopeHash(for: current) else {
                throw LedgerError.corruptedLedger
            }

            previous = current
        }
    }

    private static func recomputeEnvelopeHash(for entry: LedgerEntry) -> String {
        LedgerEntry.computeEnvelopeHash(
            rollbackCounter: entry.rollbackCounter,
            requestHash: entry.requestHash,
            responseHash: entry.responseHash,
            previousHash: entry.previousHash,
            eventTypeRaw: entry.eventTypeRaw,
            trustStateRaw: entry.trustStateRaw,
            handoffClassRaw: entry.handoffClassRaw,
            operationClassRaw: entry.operationClassRaw,
            capabilityClassRaw: entry.capabilityClassRaw,
            policyVersion: entry.policyVersion,
            ledgerDomain: entry.ledgerDomain,
            bindingID: entry.bindingID,
            sandboxMeasurement: entry.sandboxMeasurement,
            terminalMeasurement: entry.terminalMeasurement,
            attestationHash: entry.attestationHash
        )
    }
}
