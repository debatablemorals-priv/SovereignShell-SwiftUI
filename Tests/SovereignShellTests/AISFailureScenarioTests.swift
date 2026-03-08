import XCTest
@testable import SovereignShell_SwiftUI

final class AISFailureScenarioTests: XCTestCase {

    private func makeLedgerStore(filename: String = UUID().uuidString) -> LedgerStore {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("AISFailureScenarioTests", isDirectory: true)

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

    func testTruncatedLedgerRejected() throws {
        let store = makeLedgerStore(filename: "truncated-ledger")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()

        for i in 0..<25 {
            try ledger.append(request: "cmd\(i)", response: "ok\(i)")
        }

        let originalEntries = try store.load()
        XCTAssertEqual(originalEntries.count, 26)

        let truncatedEntries = Array(originalEntries.dropLast(5))
        try store.save(truncatedEntries)

        XCTAssertThrowsError(
            try ledger.verifyAgainstRollbackCounter(25)
        ) { error in
            XCTAssertEqual(error as? LedgerError, .rollbackViolation)
        }
    }

    func testOutOfOrderRollbackCounterRejected() throws {
        let store = makeLedgerStore(filename: "out-of-order-rollback")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()
        try ledger.append(request: "cmd1", response: "ok1")
        try ledger.append(request: "cmd2", response: "ok2")

        var entries = try store.load()
        XCTAssertEqual(entries.count, 3)

        let corrupted = LedgerEntry(
            rollbackCounter: 999,
            requestHash: entries[2].requestHash,
            responseHash: entries[2].responseHash,
            previousHash: entries[2].previousHash
        )

        entries[2] = corrupted
        try store.save(entries)

        XCTAssertThrowsError(
            try LedgerChainValidator.validate(store.load())
        )
    }

    func testPreviousHashMismatchRejected() throws {
        let store = makeLedgerStore(filename: "previous-hash-mismatch")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()
        try ledger.append(request: "cmd1", response: "ok1")
        try ledger.append(request: "cmd2", response: "ok2")

        var entries = try store.load()
        XCTAssertEqual(entries.count, 3)

        let corrupted = LedgerEntry(
            rollbackCounter: entries[2].rollbackCounter,
            requestHash: entries[2].requestHash,
            responseHash: entries[2].responseHash,
            previousHash: String(repeating: "a", count: 64)
        )

        entries[2] = corrupted
        try store.save(entries)

        XCTAssertThrowsError(
            try LedgerChainValidator.validate(store.load())
        )
    }

    func testMalformedLedgerFileRejected() throws {
        let store = makeLedgerStore(filename: "malformed-ledger-file")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()

        let badData = Data("THIS_IS_NOT_VALID_LEDGER_JSON".utf8)
        try badData.write(to: store.fileURL)

        XCTAssertThrowsError(
            try store.load()
        )
    }

    func testReplayAfterRestartRejected() throws {
        let store = makeLedgerStore(filename: "replay-after-restart")
        let ledgerA = makeLedger(store: store, rollbackCounter: 0)

        try ledgerA.bootstrap()

        for i in 0..<30 {
            try ledgerA.append(request: "cmd\(i)", response: "ok\(i)")
        }

        let fullEntries = try store.load()
        XCTAssertEqual(fullEntries.count, 31)

        let replayedEntries = Array(fullEntries.prefix(10))
        try store.save(replayedEntries)

        let ledgerB = makeLedger(store: store, rollbackCounter: 30)

        XCTAssertThrowsError(
            try ledgerB.bootstrap()
        ) { error in
            XCTAssertEqual(error as? LedgerError, .rollbackViolation)
        }
    }

    func testBreachAfterCorruptionLeavesLedgerLocked() throws {
        let store = makeLedgerStore(filename: "breach-after-corruption")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()
        try ledger.append(request: "cmd1", response: "ok1")

        var entries = try store.load()
        XCTAssertEqual(entries.count, 2)

        let corrupted = LedgerEntry(
            rollbackCounter: entries[1].rollbackCounter,
            requestHash: String(repeating: "f", count: 64),
            responseHash: entries[1].responseHash,
            previousHash: entries[1].previousHash
        )

        entries[1] = corrupted
        try store.save(entries)

        let disposition = try ledger.handleSecurityEvent(.ledgerCorruption)

        XCTAssertEqual(disposition, .locked)
        XCTAssertTrue(ledger.lockedState())

        XCTAssertThrowsError(
            try ledger.append(request: "after-corruption", response: "denied")
        )
    }
}
