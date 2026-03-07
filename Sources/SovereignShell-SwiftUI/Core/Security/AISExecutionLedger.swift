import Foundation
import CommonCrypto

public final class AISExecutionLedger {

    private let store: LedgerStore
    private let logger: SecureLogger
    private var rollbackCounter: UInt64
    private var isLocked: Bool = false

    public init(
        store: LedgerStore,
        logger: SecureLogger,
        initialRollbackCounter: UInt64
    ) {
        self.store = store
        self.logger = logger
        self.rollbackCounter = initialRollbackCounter
    }

    public func bootstrap() throws {
        do {
            let entries = try store.load()
            try LedgerChainValidator.validate(entries)

            guard let last = entries.last else {
                throw LedgerError.invalidGenesis
            }

            guard last.rollbackCounter == rollbackCounter else {
                logger.security("AIS rollback binding mismatch during bootstrap.")
                isLocked = true
                throw LedgerError.rollbackViolation
            }

            logger.security("AIS bootstrap verification passed.")
        } catch LedgerError.ledgerNotFound {
            let genesis = makeGenesisEntry()
            try store.save([genesis])
            rollbackCounter = genesis.rollbackCounter
            logger.security("AIS genesis entry created deterministically.")
        } catch {
            logger.security("AIS bootstrap verification failed. Execution halted.")
            isLocked = true
            throw error
        }
    }

    public func append(
        request: String,
        response: String
    ) throws {
        guard !isLocked else {
            logger.security("AIS append blocked because ledger is locked.")
            throw LedgerError.corruptedLedger
        }

        var entries = try store.load()
        try LedgerChainValidator.validate(entries)

        guard let previous = entries.last else {
            logger.security("AIS append failed because genesis is missing.")
            isLocked = true
            throw LedgerError.invalidGenesis
        }

        let nextRollbackCounter = rollbackCounter + 1

        let entry = LedgerEntry(
            rollbackCounter: nextRollbackCounter,
            requestHash: canonicalHash(for: request),
            responseHash: canonicalHash(for: response),
            previousHash: previous.envelopeHash
        )

        entries.append(entry)

        do {
            try store.save(entries)
            rollbackCounter = nextRollbackCounter
            logger.security("AIS ledger append committed successfully.")
        } catch {
            logger.security("AIS atomic commit failed. Execution halted.")
            isLocked = true
            throw LedgerError.persistenceFailure
        }
    }

    public func verifyAgainstRollbackCounter(_ expectedRollbackCounter: UInt64) throws {
        let entries = try store.load()
        try LedgerChainValidator.validate(entries)

        guard let last = entries.last else {
            logger.security("AIS verification failed because genesis is missing.")
            isLocked = true
            throw LedgerError.invalidGenesis
        }

        guard last.rollbackCounter == expectedRollbackCounter else {
            logger.security("AIS rollback binding mismatch detected.")
            isLocked = true
            throw LedgerError.rollbackViolation
        }
    }

    public func currentRollbackCounter() -> UInt64 {
        rollbackCounter
    }

    public func lockedState() -> Bool {
        isLocked
    }

    public func lock() {
        isLocked = true
        logger.security("AIS ledger manually locked.")
    }

    private func makeGenesisEntry() -> LedgerEntry {
        LedgerEntry(
            rollbackCounter: rollbackCounter,
            requestHash: canonicalHash(for: "GENESIS_REQUEST"),
            responseHash: canonicalHash(for: "GENESIS_RESPONSE"),
            previousHash: String(repeating: "0", count: 64)
        )
    }

    private func canonicalHash(for value: String) -> String {
        let ddata = Data(value.utf8)
        return data.sha256HexString()
    }
}

private extension Data {
    func sha256HexString() -> String {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        self.withUnsafeBytes { buffer in
            _ = CC_SHA256(buffer.baseAddress, CC_LONG(buffer.count), &hash)
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}
