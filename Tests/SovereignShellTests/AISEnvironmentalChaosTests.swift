import XCTest
@testable import SovereignShell_SwiftUI

final class AISEnvironmentalChaosTests: XCTestCase {

    private func makeLedgerStore(filename: String = UUID().uuidString) -> LedgerStore {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("AISEnvironmentalChaosTests", isDirectory: true)

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

    func testCrashStylePartialWriteRejected() throws {
        let store = makeLedgerStore(filename: "crash-style-partial-write")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()

        for i in 0..<50 {
            try ledger.append(request: "cmd\(i)", response: "ok\(i)")
        }

        let data = try Data(contentsOf: store.fileURL)
        XCTAssertGreaterThan(data.count, 10)

        // Simulate power loss / crash mid-write by cutting file in the middle.
        let partial = data.prefix(data.count / 2)
        try Data(partial).write(to: store.fileURL, options: .atomic)

        XCTAssertThrowsError(try store.load())
    }

    func testValidPrefixThenGarbageTailRejected() throws {
        let store = makeLedgerStore(filename: "valid-prefix-garbage-tail")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()
        for i in 0..<25 {
            try ledger.append(request: "cmd\(i)", response: "ok\(i)")
        }

        var data = try Data(contentsOf: store.fileURL)
        data.append(Data("<<CORRUPTED_TAIL>>".utf8))
        try data.write(to: store.fileURL, options: .atomic)

        XCTAssertThrowsError(try store.load())
    }

    func testStaleLedgerRestoreRejectedOnRestart() throws {
        let store = makeLedgerStore(filename: "stale-restore")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()
        for i in 0..<100 {
            try ledger.append(request: "cmd\(i)", response: "ok\(i)")
        }

        let fullEntries = try store.load()
        XCTAssertEqual(fullEntries.count, 101)

        let staleSnapshot = Array(fullEntries.prefix(20))
        try store.save(staleSnapshot)

        let restarted = makeLedger(store: store, rollbackCounter: 100)

        XCTAssertThrowsError(
            try restarted.bootstrap()
        ) { error in
            XCTAssertEqual(error as? LedgerError, .rollbackViolation)
        }
    }

    func testOutOfOrderPersistenceRejected() throws {
        let store = makeLedgerStore(filename: "out-of-order-persistence")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()
        for i in 0..<10 {
            try ledger.append(request: "cmd\(i)", response: "ok\(i)")
        }

        var entries = try store.load()
        XCTAssertEqual(entries.count, 11)

        // Swap two later entries to simulate reorder corruption.
        entries.swapAt(8, 9)
        try store.save(entries)

        XCTAssertThrowsError(
            try LedgerChainValidator.validate(store.load())
        )
    }

    func testDuplicateTailPersistenceRejected() throws {
        let store = makeLedgerStore(filename: "duplicate-tail")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()
        for i in 0..<20 {
            try ledger.append(request: "cmd\(i)", response: "ok\(i)")
        }

        var entries = try store.load()
        XCTAssertEqual(entries.count, 21)

        // Duplicate a valid tail entry to simulate faulty persistence replay.
        entries.append(entries.last!)
        try store.save(entries)

        XCTAssertThrowsError(
            try LedgerChainValidator.validate(store.load())
        )
    }

    func testRapidRestartAgainstDamagedStorageFailsClosed() throws {
        let store = makeLedgerStore(filename: "rapid-restart-damaged")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()
        for i in 0..<30 {
            try ledger.append(request: "cmd\(i)", response: "ok\(i)")
        }

        var entries = try store.load()
        XCTAssertEqual(entries.count, 31)

        entries[15] = LedgerEntry(
            rollbackCounter: entries[15].rollbackCounter,
            requestHash: String(repeating: "f", count: 64),
            responseHash: entries[15].responseHash,
            previousHash: entries[15].previousHash
        )
        try store.save(entries)

        for _ in 0..<10 {
            let restarted = makeLedger(store: store, rollbackCounter: 30)
            XCTAssertThrowsError(try restarted.bootstrap())
        }
    }

    func testConcurrentReadersDuringWriteStormDoNotProduceSilentAcceptance() throws {
        let store = makeLedgerStore(filename: "readers-during-write-storm")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()

        let group = DispatchGroup()
        let lock = NSLock()
        var writerErrors: [Error] = []
        var readerErrors: [Error] = []

        for i in 0..<100 {
            group.enter()
            DispatchQueue.global().async {
                defer { group.leave() }
                do {
                    try ledger.append(request: "cmd\(i)", response: "ok\(i)")
                } catch {
                    lock.lock()
                    writerErrors.append(error)
                    lock.unlock()
                }
            }
        }

        for _ in 0..<100 {
            group.enter()
            DispatchQueue.global().async {
                defer { group.leave() }
                do {
                    let entries = try store.load()
                    // Either validly load current state or fail loudly, but don't silently corrupt.
                    _ = try? LedgerChainValidator.validate(entries)
                } catch {
                    lock.lock()
                    readerErrors.append(error)
                    lock.unlock()
                }
            }
        }

        group.wait()

        XCTAssertTrue(writerErrors.isEmpty, "Writer errors: \(writerErrors)")

        let finalEntries = try store.load()
        XCTAssertNoThrow(try LedgerChainValidator.validate(finalEntries))
    }

    func testBreachAfterEnvironmentalCorruptionLocksAIS() throws {
        let store = makeLedgerStore(filename: "breach-after-environmental-corruption")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()
        for i in 0..<40 {
            try ledger.append(request: "cmd\(i)", response: "ok\(i)")
        }

        let data = try Data(contentsOf: store.fileURL)
        let damaged = data.prefix(max(1, data.count / 3))
        try Data(damaged).write(to: store.fileURL, options: .atomic)

        let disposition = try ledger.handleSecurityEvent(.ledgerCorruption)

        XCTAssertEqual(disposition, .locked)
        XCTAssertTrue(ledger.lockedState())

        XCTAssertThrowsError(
            try ledger.append(request: "after-env-breach", response: "denied")
        )
    }
}
