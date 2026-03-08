import Foundation
import CryptoKit

final class AISExecutionLedger {
    private let store: LedgerStore
    private let logger: SecureLogger
    private let stateLock = NSRecursiveLock()

    private var rollbackCounter: UInt64
    private var isLocked: Bool = false

    init(
        store: LedgerStore,
        logger: SecureLogger,
        initialRollbackCounter: UInt64
    ) {
        self.store = store
        self.logger = logger
        self.rollbackCounter = initialRollbackCounter
    }

    func bootstrap() throws {
        stateLock.lock()
        defer { stateLock.unlock() }

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

    func append(
        request: String,
        response: String
    ) throws {
        stateLock.lock()
        defer { stateLock.unlock() }

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
            logger.security("AIS event append committed successfully.")
        } catch {
            logger.security("AIS atomic commit failed. Execution halted.")
            isLocked = true
            throw LedgerError.persistenceFailure
        }
    }

    func append(event: AISEvent) throws {
        stateLock.lock()
        defer { stateLock.unlock() }

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

        guard event.previousHash == previous.envelopeHash else {
            logger.security("AIS event previous-hash mismatch detected.")
            isLocked = true
            throw LedgerError.corruptedLedger
        }

        let entry = LedgerEntry(event: event)
        entries.append(entry)

        do {
            try store.save(entries)
            rollbackCounter = event.rollbackCounter
            logger.security("AIS event append committed successfully.")
        } catch {
            logger.security("AIS atomic commit failed. Execution halted.")
            isLocked = true
            throw LedgerError.persistenceFailure
        }
    }

    @discardableResult
    func handleSecurityEvent(_ securityEvent: AISSecurityEvent) throws -> AISSecretDisposition {
        stateLock.lock()
        defer { stateLock.unlock() }

        let disposition = AISBreachDetector.disposition(for: securityEvent)
        let eventType = AISBreachDetector.eventType(for: securityEvent)
        let trustState = AISBreachDetector.trustState(for: securityEvent)
        let nextRollbackCounter = rollbackCounter + 1

        let event = AISEvent(
            rollbackCounter: nextRollbackCounter,
            timestamp: nextRollbackCounter,
            eventType: eventType,
            trustState: trustState,
            handoffClass: .none,
            previousHash: try currentPreviousHashLocked()
        )

        do {
            try append(event: event)
            logger.security("AIS security event handled: \(eventType.rawValue)")
        } catch {
            isLocked = true
            throw error
        }

        isLocked = true
        return disposition
    }

    func verifyAgainstRollbackCounter(_ expectedRollbackCounter: UInt64) throws {
        stateLock.lock()
        defer { stateLock.unlock() }

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

    func currentRollbackCounter() -> UInt64 {
        stateLock.lock()
        defer { stateLock.unlock() }
        return rollbackCounter
    }

    func lockedState() -> Bool {
        stateLock.lock()
        defer { stateLock.unlock() }
        return isLocked
    }

    func lock() {
        stateLock.lock()
        defer { stateLock.unlock() }

        isLocked = true
        logger.security("AIS ledger manually locked.")
    }

    func currentLedgerPreviousHash() throws -> String {
        stateLock.lock()
        defer { stateLock.unlock() }
        return try currentPreviousHashLocked()
    }

    private func makeGenesisEntry() -> LedgerEntry {
        LedgerEntry(
            rollbackCounter: rollbackCounter,
            requestHash: canonicalHash(for: "GENESIS_REQUEST"),
            responseHash: canonicalHash(for: "GENESIS_RESPONSE"),
            previousHash: String(repeating: "0", count: 64)
        )
    }

    private func currentPreviousHashLocked() throws -> String {
        let entries = try store.load()
        try LedgerChainValidator.validate(entries)

        guard let previous = entries.last else {
            logger.security("AIS append failed because genesis is missing.")
            isLocked = true
            throw LedgerError.invalidGenesis
        }

        return previous.envelopeHash
    }

    private func canonicalHash(for value: String) -> String {
        let data = Data(value.utf8)
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
