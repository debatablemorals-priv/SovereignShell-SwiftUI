import Foundation

public struct LedgerChainValidator {

    public static func validate(_ entries: [LedgerEntry]) throws {

        guard !entries.isEmpty else {
            throw LedgerError.invalidGenesis
        }

        for i in 1..<entries.count {

            let current = entries[i]
            let previous = entries[i - 1]

            if current.previousHash != previous.envelopeHash {
                throw LedgerError.invalidHashChain
            }

            if current.rollbackCounter < previous.rollbackCounter {
                throw LedgerError.rollbackViolation
            }
        }
    }
}
