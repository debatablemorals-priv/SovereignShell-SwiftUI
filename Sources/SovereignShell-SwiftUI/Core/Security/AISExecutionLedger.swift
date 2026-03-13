import Foundation
import CryptoKit

final class AISExecutionLedger {
    private let store: LedgerStore
    private let logger: SecureLogger
    private let stateLock = NSRecursiveLock()

    private let policyVersion: AISPolicyVersion = .v1
    private let ledgerDomain: AISLedgerDomain = .sandboxTerminalV1

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
            let genesis = try makeGenesisEntry()
            try store.save([genesis])
            rollbackCounter = genesis.rollbackCounter
            logger.security("AIS genesis entry created deterministically.")
        } catch {
            logger.security("AIS bootstrap verification failed. Execution halted.")
            isLocked = true
            throw error
        }
    }

    func append(request: String, response: String) throws {
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
        let envelope = try makeAttestationEnvelope(
            rollbackCounter: nextRollbackCounter,
            operationClass: .commandExecution,
            capabilityClass: .none,
            handoffClass: .none,
            trustState: .trusted,
            previousHash: previous.envelopeHash
        )

        let entry = LedgerEntry(
            rollbackCounter: nextRollbackCounter,
            requestHash: canonicalHash(for: request),
            responseHash: canonicalHash(for: response),
            previousHash: previous.envelopeHash,
            eventTypeRaw: AISEventType.command.rawValue,
            trustStateRaw: AISTrustState.trusted.rawValue,
            handoffClassRaw: AISHandoffClass.none.rawValue,
            operationClassRaw: envelope.operationClass.rawValue,
            capabilityClassRaw: envelope.capabilityClass.rawValue,
            policyVersion: envelope.policyVersion.rawValue,
            ledgerDomain: envelope.ledgerDomain.rawValue,
            bindingID: envelope.bindingID,
            sandboxMeasurement: envelope.sandboxMeasurement,
            terminalMeasurement: envelope.terminalMeasurement,
            attestationHash: envelope.attestationHash
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
        var entries = try store.load()
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

        if let bindingID = event.bindingID {
            let currentBinding = try environmentBinding()
            guard bindingID == currentBinding.bindingID.rawValue else {
                logger.security("AIS environment binding mismatch detected.")
                isLocked = true
                throw LedgerError.rollbackViolation
            }
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
        let binding = try environmentBinding()

        let event = AISEvent(
            rollbackCounter: nextRollbackCounter,
            timestamp: nextRollbackCounter,
            eventType: eventType,
            trustState: trustState,
            handoffClass: .none,
            previousHash: try currentPreviousHashLocked(),
            operationClass: .securityEvent,
            capabilityClass: .none,
            policyVersion: binding.policyVersion,
            ledgerDomain: binding.ledgerDomain,
            bindingID: binding.bindingID.rawValue,
            sandboxMeasurement: binding.measurement.sandboxMeasurement,
            terminalMeasurement: binding.measurement.terminalMeasurement
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

    func currentBindingID() throws -> String {
        try environmentBinding().bindingID.rawValue
    }

    private func makeGenesisEntry() throws -> LedgerEntry {
        let binding = try environmentBinding()

        return LedgerEntry(
            rollbackCounter: rollbackCounter,
            requestHash: canonicalHash(for: "GENESIS_REQUEST"),
            responseHash: canonicalHash(for: "GENESIS_RESPONSE"),
            previousHash: String(repeating: "0", count: 64),
            eventTypeRaw: AISEventType.boot.rawValue,
            trustStateRaw: AISTrustState.trusted.rawValue,
            handoffClassRaw: AISHandoffClass.none.rawValue,
            operationClassRaw: AISOperationClass.boot.rawValue,
            capabilityClassRaw: AISCapabilityClass.none.rawValue,
            policyVersion: binding.policyVersion.rawValue,
            ledgerDomain: binding.ledgerDomain.rawValue,
            bindingID: binding.bindingID.rawValue,
            sandboxMeasurement: binding.measurement.sandboxMeasurement,
            terminalMeasurement: binding.measurement.terminalMeasurement,
            attestationHash: canonicalHash(
                for: [
                    binding.bindingID.rawValue,
                    binding.measurement.sandboxMeasurement,
                    binding.measurement.terminalMeasurement,
                    policyVersion.rawValue,
                    ledgerDomain.rawValue
                ].joined(separator: "|")
            )
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

    private func environmentBinding() throws -> AISEnvironmentBinding {
        let anchor = try AISRootAnchor.loadOrCreate(at: rootAnchorURL())
        let measurement = runtimeMeasurement()

        return AISEnvironmentBinding(
            rootAnchor: anchor,
            measurement: measurement,
            policyVersion: policyVersion,
            ledgerDomain: ledgerDomain
        )
    }

    private func makeAttestationEnvelope(
        rollbackCounter: UInt64,
        operationClass: AISOperationClass,
        capabilityClass: AISCapabilityClass,
        handoffClass: AISHandoffClass,
        trustState: AISTrustState,
        previousHash: String
    ) throws -> AISAttestationEnvelope {
        let binding = try environmentBinding()

        return AISAttestationEnvelope(
            rollbackCounter: rollbackCounter,
            timestamp: UInt64(Date().timeIntervalSince1970),
            operationClass: operationClass,
            capabilityClass: capabilityClass,
            handoffClass: handoffClass,
            trustState: trustState,
            bindingID: binding.bindingID.rawValue,
            sandboxMeasurement: binding.measurement.sandboxMeasurement,
            terminalMeasurement: binding.measurement.terminalMeasurement,
            policyVersion: binding.policyVersion,
            ledgerDomain: binding.ledgerDomain,
            previousHash: previousHash
        )
    }

    private func runtimeMeasurement() -> AISRuntimeMeasurement {
        AISRuntimeMeasurement(
            sandboxComponents: [
                "ais-sandbox",
                "ledger-scope:\(store.fileURL.deletingLastPathComponent().lastPathComponent)",
                "policy:\(policyVersion.rawValue)",
                "domain:\(ledgerDomain.rawValue)"
            ],
            terminalComponents: [
                "ais-terminal",
                "runtime:\(String(describing: AISExecutionLedger.self))",
                "logger:\(String(describing: SecureLogger.self))",
                "locked:\(isLocked)",
                "platform:\(ProcessInfo.processInfo.operatingSystemVersionString)"
            ]
        )
    }

    private func rootAnchorURL() -> URL {
        store.fileURL
            .deletingLastPathComponent()
            .appendingPathComponent(".ais-root-anchor")
    }

    private func canonicalHash(for value: String) -> String {
        let data = Data(value.utf8)
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
