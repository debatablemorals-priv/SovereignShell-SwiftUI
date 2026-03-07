import Foundation
import CryptoKit

final class AISExecutionLedger {
    private let store: LedgerStore
    private let logger: SecureLogger
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
        let event = AISEventFactory.commandEvent(
            rollbackCounter: rollbackCounter + 1,
            previousHash: try currentPreviousHash()
        )

        try append(event: event)

        _ = canonicalHash(for: request)
        _ = canonicalHash(for: response)
    }

    func append(event: AISEvent) throws {
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

        let entry = LedgerEntry(
            rollbackCounter: event.rollbackCounter,
            requestHash: canonicalHash(for: event.eventType.rawValue),
            responseHash: canonicalHash(for: event.trustState.rawValue + "|" + event.handoffClass.rawValue),
            previousHash: event.previousHash
        )

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
        let disposition = AISBreachDetector.disposition(for: securityEvent)
        let eventType = AISBreachDetector.eventType(for: securityEvent)
        let trustState = AISBreachDetector.trustState(for: securityEvent)

        isLocked = true

        let event = AISEvent(
            rollbackCounter: rollbackCounter + 1,
            eventType: eventType,
            trustState: trustState,
            handoffClass: .none,
            previousHash: try currentPreviousHash()
        )

        try append(event: event)
        logger.security("AIS security event handled: \(eventType.rawValue)")

        return disposition}

    func verifyAgainstRollbackCounter(_ expectedRollbackCounter: UInt64) throws {
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
        rollbackCounter
    }

    func lockedState() -> Bool {
        isLocked
    }

    func lock() {
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

    private func currentPreviousHash() throws -> String {
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
