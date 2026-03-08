import Foundation
import CryptoKit

enum LedgerChainValidator {

    static func validate(_ entries: [LedgerEntry]) throws {

        guard !entries.isEmpty else {
            throw LedgerError.invalidGenesis
        }

        let genesis = entries[0]

        // Genesis must have zeroed previous hash
        guard genesis.previousHash == String(repeating: "0", count: 64) else {
            throw LedgerError.invalidGenesis
        }

        // Genesis hash must be correct
        guard genesis.envelopeHash == recomputeEnvelopeHash(for: genesis) else {
            throw LedgerError.corruptedLedger
        }

        if entries.count == 1 {
            return
        }

        var previous = genesis

        for current in entries.dropFirst() {

            // Chain pointer must match
            guard current.previousHash == previous.envelopeHash else {
                throw LedgerError.corruptedLedger
            }

            // Rollback must strictly increase
            guard current.rollbackCounter > previous.rollbackCounter else {
                throw LedgerError.rollbackViolation
            }

            // Stored envelope hash must match recomputed hash
            guard current.envelopeHash == recomputeEnvelopeHash(for: current) else {
                throw LedgerError.corruptedLedger
            }

            previous = current
        }
    }

    private static func recomputeEnvelopeHash(for entry: LedgerEntry) -> String {

        let payload = [
            String(entry.rollbackCounter),
            entry.requestHash,
            entry.responseHash,
            entry.previousHash
        ].joined(separator: "|")

        let digest = SHA256.hash(data: Data(payload.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
