import XCTest
@testable import SovereignShell_SwiftUI

final class AISSideChannelTests: XCTestCase {

    private func makeLedgerStore(filename: String = UUID().uuidString) -> LedgerStore {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("AISSideChannelTests", isDirectory: true)

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

    private func duration(_ block: () throws -> Void) rethrows -> TimeInterval {
        let start = CFAbsoluteTimeGetCurrent()
        try block()
        let end = CFAbsoluteTimeGetCurrent()
        return end - start
    }

    func testAppendTimingConsistencyAcrossNormalCommands() throws {
        let store = makeLedgerStore(filename: "append-timing-normal")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()

        var timings: [TimeInterval] = []

        for i in 0..<100 {
            let t = try duration {
                try ledger.append(request: "cmd\(i)", response: "ok\(i)")
            }
            timings.append(t)
        }

        let avg = timings.reduce(0, +) / Double(timings.count)
        XCTAssertGreaterThan(avg, 0)

        // Very loose sanity bound to catch pathological variance, not microbenchmark drift.
        let maxTiming = timings.max() ?? 0
        let minTiming = timings.min() ?? 0
        XCTAssertLessThan(maxTiming - minTiming, 0.1)
    }

    func testValidationTimingDoesNotExplodeOnSingleCorruptionLocation() throws {
        let cleanStore = makeLedgerStore(filename: "timing-clean")
        let corruptedStoreA = makeLedgerStore(filename: "timing-corrupt-a")
        let corruptedStoreB = makeLedgerStore(filename: "timing-corrupt-b")

        let cleanLedger = makeLedger(store: cleanStore, rollbackCounter: 0)
        let ledgerA = makeLedger(store: corruptedStoreA, rollbackCounter: 0)
        let ledgerB = makeLedger(store: corruptedStoreB, rollbackCounter: 0)

        try cleanLedger.bootstrap()
        try ledgerA.bootstrap()
        try ledgerB.bootstrap()

        for i in 0..<1000 {
            try cleanLedger.append(request: "cmd\(i)", response: "ok\(i)")
            try ledgerA.append(request: "cmd\(i)", response: "ok\(i)")
            try ledgerB.append(request: "cmd\(i)", response: "ok\(i)")
        }

        var entriesA = try corruptedStoreA.load()
        var entriesB = try corruptedStoreB.load()

        entriesA[10] = LedgerEntry(
            rollbackCounter: entriesA[10].rollbackCounter,
            requestHash: String(repeating: "a", count: 64),
            responseHash: entriesA[10].responseHash,
            previousHash: entriesA[10].previousHash
        )

        entriesB[900] = LedgerEntry(
            rollbackCounter: entriesB[900].rollbackCounter,
            requestHash: String(repeating: "b", count: 64),
            responseHash: entriesB[900].responseHash,
            previousHash: entriesB[900].previousHash
        )

        try corruptedStoreA.save(entriesA)
        try corruptedStoreB.save(entriesB)

        let tA = duration {
            XCTAssertThrowsError(try LedgerChainValidator.validate(corruptedStoreA.load()))
        }

        let tB = duration {
            XCTAssertThrowsError(try LedgerChainValidator.validate(corruptedStoreB.load()))
        }

        // Loose bound: validation timing should not wildly disclose corruption position.
        XCTAssertLessThan(abs(tA - tB), 0.1)
    }

func testLockedLedgerRejectsConsistently() throws {
        let store = makeLedgerStore(filename: "locked-reject-consistency")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()
        _ = try ledger.handleSecurityEvent(.ledgerCorruption)

        var timings: [TimeInterval] = []

        for i in 0..<100 {
            let t = duration {
                XCTAssertThrowsError(
                    try ledger.append(request: "blocked\(i)", response: "denied")
                )
            }
            timings.append(t)
        }

        let maxTiming = timings.max() ?? 0
        let minTiming = timings.min() ?? 0
        XCTAssertLessThan(maxTiming - minTiming, 0.05)
    }

    func testReplayAndRollbackViolationBothFailWithoutPathologicalTimingGap() throws {
        let storeA = makeLedgerStore(filename: "timing-replay")
        let storeB = makeLedgerStore(filename: "timing-rollback")
        let ledgerA = makeLedger(store: storeA, rollbackCounter: 0)
        let ledgerB = makeLedger(store: storeB, rollbackCounter: 0)

        try ledgerA.bootstrap()
        try ledgerB.bootstrap()

        for i in 0..<500 {
            try ledgerA.append(request: "cmd\(i)", response: "ok\(i)")
            try ledgerB.append(request: "cmd\(i)", response: "ok\(i)")
        }

        let replayedEntries = Array((try storeA.load()).prefix(100))
        try storeA.save(replayedEntries)

        let tReplay = duration {
            XCTAssertThrowsError(try ledgerA.verifyAgainstRollbackCounter(500))
        }

        let tRollback = duration {
            XCTAssertThrowsError(try ledgerB.verifyAgainstRollbackCounter(999))
        }

        XCTAssertLessThan(abs(tReplay - tRollback), 0.1)
    }
}
