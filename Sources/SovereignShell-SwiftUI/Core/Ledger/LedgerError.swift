import Foundation

public enum LedgerError: Error {
    case ledgerNotFound
    case corruptedLedger
    case invalidGenesis
    case invalidHashChain
    case rollbackViolation
    case serializationFailure
    case persistenceFailure
}
