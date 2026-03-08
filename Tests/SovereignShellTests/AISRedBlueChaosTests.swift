import XCTest
@testable import SovereignShell_SwiftUI

final class AISRedBlueChaosTests: XCTestCase {

    private func makeLedgerStore(filename: String = UUID().uuidString) -> LedgerStore {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("AISRedBlueChaosTests", isDirectory: true)

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

    func testForgedEntryInjectionRejected() throws {
        let store = makeLedgerStore(filename: "forged-entry")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()
        try ledger.append(request: "cmd1", response: "ok1")
        try ledger.append(request: "cmd2", response: "ok2")

        var entries = try store.load()
        XCTAssertEqual(entries.count, 3)

        let forged = LedgerEntry(
            rollbackCounter: 3,
            requestHash: String(repeating: "e", count: 64),
            responseHash: String(repeating: "f", count: 64),
            previousHash: String(repeating: "0", count: 64)
        )

        entries.append(forged)
        try store.save(entries)

        XCTAssertThrowsError(
            try LedgerChainValidator.validate(store.load())
        )
    }

    func testChainSpliceAttackRejected() throws {
        let storeA = makeLedgerStore(filename: "splice-a")
        let storeB = makeLedgerStore(filename: "splice-b")

        let ledgerA = makeLedger(store: storeA, rollbackCounter: 0)
        let ledgerB = makeLedger(store: storeB, rollbackCounter: 0)

        try ledgerA.bootstrap()
        try ledgerB.bootstrap()

        for i in 0..<20 {
            try ledgerA.append(request: "a\(i)", response: "ok\(i)")
            try ledgerB.append(request: "b\(i)", response: "ok\(i)")
        }

        let chainA = try storeA.load()
        let chainB = try storeB.load()

        let spliced = Array(chainA.prefix(10)) + Array(chainB.suffix(10))
        try storeA.save(spliced)

        XCTAssertThrowsError(
            try LedgerChainValidator.validate(storeA.load())
        )
    }

    func testReplaySnapshotAttackRejected() throws {
        let store = makeLedgerStore(filename: "replay-snapshot")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()

        for i in 0..<100 {
            try ledger.append(request: "cmd\(i)", response: "ok\(i)")
        }

        let entries = try store.load()
        XCTAssertEqual(entries.count, 101)

        let replayed = Array(entries.prefix(15))
        try store.save(replayed)

        XCTAssertThrowsError(
            try ledger.verifyAgainstRollbackCounter(100)
        ) { error in
            XCTAssertEqual(error as? LedgerError, .rollbackViolation)
        }
    }

    func testTruncatedFileAttackRejected() throws {
        let store = makeLedgerStore(filename: "truncated-file")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()
        try ledger.append(request: "cmd", response: "ok")

        let data = try Data(contentsOf: store.fileURL)
        let truncated = data.prefix(max(1, data.count / 2))
        try Data(truncated).write(to: store.fileURL)

        XCTAssertThrowsError(
            try store.load()
        )
    }

    func testMalformedPayloadAttackRejected() throws {
        let store = makeLedgerStore(filename: "malformed-payload")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()

        let bad = Data("<<NOT_A_VALID_LEDGER_FILE>>".utf8)
        try bad.write(to: store.fileURL)

        XCTAssertThrowsError(
            try store.load()
        )
    }

    func testMultiPointCorruptionAttackRejected() throws {
        let store = makeLedgerStore(filename: "multi-point-corruption")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()

        for i in 0..<500 {
            try ledger.append(request: "cmd\(i)", response: "ok\(i)")
        }

        var entries = try store.load()
        XCTAssertEqual(entries.count, 501)

        entries[50] = LedgerEntry(
            rollbackCounter: entries[50].rollbackCounter,
            requestHash: String(repeating: "a", count: 64),
            responseHash: entries[50].responseHash,
            previousHash: entries[50].previousHash
        )

        entries[250] = LedgerEntry(
            rollbackCounter: 999_999,
            requestHash: entries[250].requestHash,
            responseHash: entries[250].responseHash,
            previousHash: entries[250].previousHash
        )

        entries[400] = LedgerEntry(
            rollbackCounter: entries[400].rollbackCounter,
            requestHash: entries[400].requestHash,
            responseHash: entries[400].responseHash,
            previousHash: String(repeating: "b", count: 64)
        )

        try store.save(entries)

        XCTAssertThrowsError(
            try LedgerChainValidator.validate(store.load())
        )
    }

    func testConcurrentAppendPressureChaos() throws {
        let store = makeLedgerStore(filename: "concurrent-chaos")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()

        let lock = NSLock()
        var errors: [Error] = []

        DispatchQueue.concurrentPerform(iterations: 250) { i in
            do {
                try ledger.append(request: "cmd\(i)", response: "ok\(i)")
            } catch {
                lock.lock()
                errors.append(error)
                lock.unlock()
            }
        }

        XCTAssertTrue(errors.isEmpty, "Concurrent append errors: \(errors)")

        let entries = try store.load()
        XCTAssertEqual(entries.count, 251)
        XCTAssertNoThrow(try LedgerChainValidator.validate(entries))
    }

    func testBreachAfterAttackLeavesAISLocked() throws {
        let store = makeLedgerStore(filename: "breach-after-attack")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()

        for i in 0..<100 {
            try ledger.append(request: "cmd\(i)", response: "ok\(i)")
        }

        var entries = try store.load()
        entries[75] = LedgerEntry(
            rollbackCounter: entries[75].rollbackCounter,
            requestHash: String(repeating: "c", count: 64),
            responseHash: entries[75].responseHash,
            previousHash: entries[75].previousHash
        )
        try store.save(entries)

        let disposition = try ledger.handleSecurityEvent(.ledgerCorruption)

        XCTAssertEqual(disposition, .locked)
        XCTAssertTrue(ledger.lockedState())

        XCTAssertThrowsError(
            try ledger.append(request: "after-breach", response: "denied")
        )
    }
}
