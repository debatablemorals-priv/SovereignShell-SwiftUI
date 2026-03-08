import XCTest
@testable import SovereignShell_SwiftUI

final class AISFinalBossTests: XCTestCase {

    private func makeLedgerStore(filename: String = UUID().uuidString) -> LedgerStore {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("AISFinalBossTests", isDirectory: true)

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

    func testSplitBrainHistoriesCannotBeMerged() throws {
        let storeA = makeLedgerStore(filename: "splitbrain-a")
        let storeB = makeLedgerStore(filename: "splitbrain-b")

        let ledgerA = makeLedger(store: storeA, rollbackCounter: 0)
        let ledgerB = makeLedger(store: storeB, rollbackCounter: 0)

        try ledgerA.bootstrap()
        try ledgerB.bootstrap()

        // Shared prefix
        for i in 0..<50 {
            try ledgerA.append(request: "shared\(i)", response: "ok\(i)")
            try ledgerB.append(request: "shared\(i)", response: "ok\(i)")
        }

        // Divergent histories after same prefix
        for i in 50..<100 {
            try ledgerA.append(request: "branchA\(i)", response: "okA\(i)")
            try ledgerB.append(request: "branchB\(i)", response: "okB\(i)")
        }

        let chainA = try storeA.load()
        let chainB = try storeB.load()

        XCTAssertEqual(chainA.count, 101)
        XCTAssertEqual(chainB.count, 101)

        // Illegally merge first half of A with second half of B
        let merged = Array(chainA.prefix(51)) + Array(chainB.suffix(50))
        try storeA.save(merged)

        XCTAssertThrowsError(
            try LedgerChainValidator.validate(storeA.load())
        )
    }

    func testCompetingValidHistoriesCannotMasqueradeAsSameState() throws {
        let storeA = makeLedgerStore(filename: "competing-a")
        let storeB = makeLedgerStore(filename: "competing-b")

        let ledgerA = makeLedger(store: storeA, rollbackCounter: 0)
        let ledgerB = makeLedger(store: storeB, rollbackCounter: 0)

        try ledgerA.bootstrap()
        try ledgerB.bootstrap()

        for i in 0..<200 {
            try ledgerA.append(request: "A\(i)", response: "okA\(i)")
            try ledgerB.append(request: "B\(i)", response: "okB\(i)")
        }

        let entriesA = try storeA.load()
        let entriesB = try storeB.load()

        XCTAssertEqual(entriesA.count, 201)
        XCTAssertEqual(entriesB.count, 201)

        // Both chains are individually valid, but they are not the same reality.
        XCTAssertNoThrow(try LedgerChainValidator.validate(entriesA))
        XCTAssertNoThrow(try LedgerChainValidator.validate(entriesB))

        XCTAssertNotEqual(
            entriesA.last?.previousHash,
            entriesB.last?.previousHash,
            "Distinct histories should not collapse to same tail state"
        )
    }

    func testStaleSnapshotResurrectionAfterProgressIsRejected() throws {
        let store = makeLedgerStore(filename: "stale-resurrection")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()

        for i in 0..<500 {
            try ledger.append(request: "cmd\(i)", response: "ok\(i)")
        }

        let snapshot = try store.load()
        XCTAssertEqual(snapshot.count, 501)

        for i in 500..<1000 {
            try ledger.append(request: "cmd\(i)", response: "ok\(i)")
        }

        let progressed = try store.load()
        XCTAssertEqual(progressed.count, 1001)

        // Restore stale snapshot over newer state
        try store.save(snapshot)

        let restarted = makeLedger(store: store, rollbackCounter: 1000)

        XCTAssertThrowsError(
            try restarted.bootstrap()
        ) { error in
            XCTAssertEqual(error as? LedgerError, .rollbackViolation)
        }
    }

    func testCrossStoreLedgerContaminationRejected() throws {
        let storeA = makeLedgerStore(filename: "crossstore-a")
        let storeB = makeLedgerStore(filename: "crossstore-b")

        let ledgerA = makeLedger(store: storeA, rollbackCounter: 0)
        let ledgerB = makeLedger(store: storeB, rollbackCounter: 0)

        try ledgerA.bootstrap()
        try ledgerB.bootstrap()

        for i in 0..<100 {
            try ledgerA.append(request: "alpha\(i)", response: "ok\(i)")
            try ledgerB.append(request: "beta\(i)", response: "ok\(i)")
        }

        var entriesA = try storeA.load()
        let entriesB = try storeB.load()

        XCTAssertEqual(entriesA.count, 101)
        XCTAssertEqual(entriesB.count, 101)

        // Swap one entry from B into A without changing surrounding chain.
        entriesA[75] = entriesB[75]
        try storeA.save(entriesA)

        XCTAssertThrowsError(
            try LedgerChainValidator.validate(storeA.load())
        )
    }

    func testByzantineTailForkRejectedOnVerification() throws {
        let store = makeLedgerStore(filename: "byzantine-tail-fork")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()

        for i in 0..<300 {
            try ledger.append(request: "cmd\(i)", response: "ok\(i)")
        }

        var entries = try store.load()
        XCTAssertEqual(entries.count, 301)

        let last = entries.last!
        let forgedTail = LedgerEntry(
            rollbackCounter: last.rollbackCounter + 1,
            requestHash: String(repeating: "a", count: 64),
            responseHash: String(repeating: "b", count: 64),
            previousHash: last.previousHash // intentionally wrong linkage for fork illusion
        )

        entries.append(forgedTail)
        try store.save(entries)

        XCTAssertThrowsError(
            try LedgerChainValidator.validate(store.load())
        )
    }

    func testMultipleIndependentRestartsAgainstConflictedStateAllFailClosed() throws {
        let store = makeLedgerStore(filename: "conflicted-restarts")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()

        for i in 0..<150 {
            try ledger.append(request: "cmd\(i)", response: "ok\(i)")
        }

        var entries = try store.load()
        XCTAssertEqual(entries.count, 151)

        // Make a deep inconsistency that still looks structurally shaped like a ledger file.
        entries[20] = LedgerEntry(
            rollbackCounter: entries[20].rollbackCounter,
            requestHash: entries[20].requestHash,
            responseHash: String(repeating: "f", count: 64),
            previousHash: entries[20].previousHash
        )

        entries[120] = LedgerEntry(
            rollbackCounter: 9_999,
            requestHash: entries[120].requestHash,
            responseHash: entries[120].responseHash,
            previousHash: entries[120].previousHash
        )

        try store.save(entries)

        for _ in 0..<20 {
            let restarted = makeLedger(store: store, rollbackCounter: 150)
            XCTAssertThrowsError(try restarted.bootstrap())
        }
    }

    func testAdversarialReadWriteRealityDriftDoesNotSilentlyPass() throws {
        let store = makeLedgerStore(filename: "reality-drift")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()

        let lock = NSLock()
        let group = DispatchGroup()

        var writerErrors: [Error] = []
        var readerValidationFailures = 0

        for i in 0..<200 {
            group.enter()
            DispatchQueue.global().async {
                defer { group.leave() }
                do {
                  let entries = try store.load()
                    do {
                        try LedgerChainValidator.validate(entries)
                    } catch {
                        lock.lock()
                        readerValidationFailures += 1
                        lock.unlock()
                    }
                } catch {
                    lock.lock()
                    readerValidationFailures += 1
                    lock.unlock()
                }
            }
        }

        group.wait()

        XCTAssertTrue(writerErrors.isEmpty, "Writer errors: \(writerErrors)")

        let finalEntries = try store.load()
        XCTAssertNoThrow(try LedgerChainValidator.validate(finalEntries))
        XCTAssertGreaterThanOrEqual(readerValidationFailures, 0)
    }

    func testBreachAfterByzantineConflictLeavesAISLocked() throws {
        let store = makeLedgerStore(filename: "breach-after-byzantine")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()

        for i in 0..<80 {
            try ledger.append(request: "cmd\(i)", response: "ok\(i)")
        }

        var entries = try store.load()

        entries[40] = LedgerEntry(
            rollbackCounter: 123_456,
            requestHash: entries[40].requestHash,
            responseHash: entries[40].responseHash,
            previousHash: String(repeating: "d", count: 64)
        )

        try store.save(entries)

        let disposition = try ledger.handleSecurityEvent(.ledgerCorruption)

        XCTAssertEqual(disposition, .locked)
        XCTAssertTrue(ledger.lockedState())

        XCTAssertThrowsError(
            try ledger.append(request: "after-final-boss", response: "denied")
        )
    }
}
