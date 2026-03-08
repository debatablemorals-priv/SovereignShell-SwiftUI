import XCTest
@testable import SovereignShell_SwiftUI

final class AISValidationTests: XCTestCase {

    private func makeLedgerStore(filename: String = UUID().uuidString) -> LedgerStore {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("AISValidationTests", isDirectory: true)

        try? FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )

        let fileURL = directory.appendingPathComponent(filename + ".chain")
        try? FileManager.default.removeItem(at: fileURL)

        return LedgerStore(fileURL: fileURL)
    }

    private func makeLedger(
        store: LedgerStore? = nil,
        rollbackCounter: UInt64 = 0
    ) -> AISExecutionLedger {
        AISExecutionLedger(
            store: store ?? makeLedgerStore(),
            logger: SecureLogger(),
            initialRollbackCounter: rollbackCounter
        )
    }

    func testBootstrapCreatesGenesisLedger() throws {
        let store = makeLedgerStore(filename: "bootstrap-genesis")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()

        let entries = try store.load()
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries.first?.rollbackCounter, 0)
    }

    func testAppendCommandCreatesSecondLedgerEntry() throws {
        let store = makeLedgerStore(filename: "append-command")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()
        try ledger.append(request: "help", response: "ok")

        let entries = try store.load()
        XCTAssertEqual(entries.count, 2)
        XCTAssertEqual(entries.last?.rollbackCounter, 1)
    }

    func testBootAttestationAppendsSuccessfully() throws {
        let store = makeLedgerStore(filename: "boot-attestation")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()

        let bootEvent = AISEventFactory.bootEvent(
            rollbackCounter: ledger.currentRollbackCounter() + 1,
            previousHash: try ledger.currentLedgerPreviousHash()
        )

        try ledger.append(event: bootEvent)

        let entries = try store.load()
        XCTAssertEqual(entries.count, 2)
        XCTAssertEqual(entries.last?.rollbackCounter, 1)
    }

    func testHandoffAttestedAppendsSuccessfully() throws {
        let store = makeLedgerStore(filename: "handoff-attested")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()

        try AISTrustHandoff.record(
            result: .attested,
            handoffClass: .network,
            ledger: ledger
        )

        let entries = try store.load()
        XCTAssertEqual(entries.count, 2)
        XCTAssertEqual(entries.last?.rollbackCounter, 1)
    }

    func testHandoffFailedAppendsSuccessfully() throws {
        let store = makeLedgerStore(filename: "handoff-failed")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()

        try AISTrustHandoff.record(
            result: .failed,
            handoffClass: .api,
            ledger: ledger
        )

        let entries = try store.load()
        XCTAssertEqual(entries.count, 2)
        XCTAssertEqual(entries.last?.rollbackCounter, 1)
    }

    func testSecurityEventLocksLedgerAndReturnsDisposition() throws {
        let store = makeLedgerStore(filename: "security-event")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()

        let disposition = try ledger.handleSecurityEvent(.ledgerCorruption)

        XCTAssertEqual(disposition, .locked)
        XCTAssertTrue(ledger.lockedState())
    }

    func testAppendFailsAfterSecurityLock() throws {
        let store = makeLedgerStore(filename: "append-after-lock")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()
        _ = try ledger.handleSecurityEvent(.ledgerCorruption)

        XCTAssertThrowsError(
            try ledger.append(request: "help", response: "blocked")
        ) { error in
            XCTAssertEqual(error as? LedgerError, .corruptedLedger)
        }
    }

    func testTamperedLedgerFailsValidation() throws {
        let store = makeLedgerStore(filename: "tampered-ledger")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()
        try ledger.append(request: "help", response: "ok")

        var entries = try store.load()
        XCTAssertEqual(entries.count, 2)

        let tampered = LedgerEntry(
            rollbackCounter: entries[1].rollbackCounter,
            requestHash: String(repeating: "f", count: 64),
            responseHash: entries[1].responseHash,
            previousHash: entries[1].previousHash
        )

        entries[1] = tampered
        try store.save(entries)

        XCTAssertThrowsError(
            try LedgerChainValidator.validate(store.load())
        )
    }

    func testRollbackMismatchFailsVerification() throws {
        let store = makeLedgerStore(filename: "rollback-mismatch")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()

        XCTAssertThrowsError(
            try ledger.verifyAgainstRollbackCounter(999)
        ) { error in
            XCTAssertEqual(error as? LedgerError, .rollbackViolation)
        }
    }

    func testAISNotaryEventCarriesTimestamp() throws {
        let event = AISEventFactory.commandEvent(
            rollbackCounter: 1,
            previousHash: String(repeating: "0", count: 64)
        )

        XCTAssertGreaterThan(event.timestamp, 0)
        XCTAssertFalse(event.envelopeHash.isEmpty)
    }
}
