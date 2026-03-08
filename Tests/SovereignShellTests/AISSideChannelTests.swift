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
        let start = Date().timeIntervalSinceReferenceDate
        try block()
        let end = Date().timeIntervalSinceReferenceDate
        return end - start
    }

    func testAppendTimingConsistencyAcross1000Commands() throws {
        let store = makeLedgerStore(filename: "append-timing-1000")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()

        var timings: [TimeInterval] = []

        for i in 0..<1000 {
            let t = try duration {
                try ledger.append(request: "cmd\(i)", response: "ok\(i)")
            }
            timings.append(t)
        }

        let maxTiming = timings.max() ?? 0
        let minTiming = timings.min() ?? 0

        XCTAssertGreaterThan(maxTiming, 0)
        XCTAssertLessThan(maxTiming - minTiming, 0.1)
    }

    func testValidationTimingAcrossCorruptionPositionsOn10KChain() throws {
        let cleanStore = makeLedgerStore(filename: "timing-clean-10k")
        let earlyStore = makeLedgerStore(filename: "timing-early-10k")
        let midStore = makeLedgerStore(filename: "timing-mid-10k")
        let lateStore = makeLedgerStore(filename: "timing-late-10k")

        let cleanLedger = makeLedger(store: cleanStore, rollbackCounter: 0)
        let earlyLedger = makeLedger(store: earlyStore, rollbackCounter: 0)
        let midLedger = makeLedger(store: midStore, rollbackCounter: 0)
        let lateLedger = makeLedger(store: lateStore, rollbackCounter: 0)

        try cleanLedger.bootstrap()
        try earlyLedger.bootstrap()
        try midLedger.bootstrap()
        try lateLedger.bootstrap()

        for i in 0..<10_000 {
            try cleanLedger.append(request: "cmd\(i)", response: "ok\(i)")
            try earlyLedger.append(request: "cmd\(i)", response: "ok\(i)")
            try midLedger.append(request: "cmd\(i)", response: "ok\(i)")
            try lateLedger.append(request: "cmd\(i)", response: "ok\(i)")
        }

        var earlyEntries = try earlyStore.load()
        var midEntries = try midStore.load()
        var lateEntries = try lateStore.load()

        earlyEntries[10] = LedgerEntry(
            rollbackCounter: earlyEntries[10].rollbackCounter,
            requestHash: String(repeating: "a", count: 64),
            responseHash: earlyEntries[10].responseHash,
            previousHash: earlyEntries[10].previousHash
        )

        midEntries[5_000] = LedgerEntry(
            rollbackCounter: midEntries[5_000].rollbackCounter,
            requestHash: String(repeating: "b", count: 64),
            responseHash: midEntries[5_000].responseHash,
            previousHash: midEntries[5_000].previousHash
        )

        lateEntries[9_999] = LedgerEntry(
            rollbackCounter: lateEntries[9_999].rollbackCounter,
            requestHash: String(repeating: "c", count: 64),
            responseHash: lateEntries[9_999].responseHash,
            previousHash: lateEntries[9_999].previousHash
        )

        try earlyStore.save(earlyEntries)
        try midStore.save(midEntries)
        try lateStore.save(lateEntries)

        let tEarly = duration {
            XCTAssertThrowsError(try LedgerChainValidator.validate(earlyStore.load()))
        }

        let tMid = duration {
            XCTAssertThrowsError(try LedgerChainValidator.validate(midStore.load()))
        }

        let tLate = duration {
            XCTAssertThrowsError(try LedgerChainValidator.validate(lateStore.load()))
        }

        XCTAssertLessThan(abs(tEarly - tMid), 0.2)
        XCTAssertLessThan(abs(tMid - tLate), 0.2)
        XCTAssertLessThan(abs(tEarly - tLate), 0.2)
    }

    func testLockedLedgerRejectsConsistentlyAcross1000Attempts() throws {
        let store = makeLedgerStore(filename: "locked-reject-1000")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()
        _ = try ledger.handleSecurityEvent(.ledgerCorruption)

        var timings: [TimeInterval] = []

        for i in 0..<1000 {
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

    func testReplayVsRollbackTimingOnLargeChains() throws {
        let storeA = makeLedgerStore(filename: "timing-replay-large")
        let storeB = makeLedgerStore(filename: "timing-rollback-large")

        let ledgerA = makeLedger(store: storeA, rollbackCounter: 0)
        let ledgerB = makeLedger(store: storeB, rollbackCounter: 0)

        try ledgerA.bootstrap()
        try ledgerB.bootstrap()

        for i in 0..<10_000 {
            try ledgerA.append(request: "cmd\(i)", response: "ok\(i)")
            try ledgerB.append(request: "cmd\(i)", response: "ok\(i)")
        }

        let replayedEntries = Array((try storeA.load()).prefix(2_000))
        try storeA.save(replayedEntries)

        let tReplay = duration {
            XCTAssertThrowsError(try ledgerA.verifyAgainstRollbackCounter(10_000))
        }

        let tRollback = duration {
            XCTAssertThrowsError(try ledgerB.verifyAgainstRollbackCounter(99_999))
        }

        XCTAssertLessThan(abs(tReplay - tRollback), 0.2)
    }

    func testBootstrapTimingCleanVsReplayedState() throws {
        let cleanStore = makeLedgerStore(filename: "bootstrap-clean")
        let replayStore = makeLedgerStore(filename: "bootstrap-replayed")

        let cleanLedger = makeLedger(store: cleanStore, rollbackCounter: 0)
        let replayLedgerA = makeLedger(store: replayStore, rollbackCounter: 0)

        try cleanLedger.bootstrap()
        try replayLedgerA.bootstrap()

        for i in 0..<5_000 {
            try cleanLedger.append(request: "cmd\(i)", response: "ok\(i)")
            try replayLedgerA.append(request: "cmd\(i)", response: "ok\(i)")
        }

        let replayedEntries = Array((try replayStore.load()).prefix(1_000))
        try replayStore.save(replayedEntries)

        let cleanBootstrapTime = duration {
            let fresh = makeLedger(store: cleanStore, rollbackCounter: 5_000)
            _ = try? fresh.bootstrap()
        }

        let replayBootstrapTime = duration {
            let replayed = makeLedger(store: replayStore, rollbackCounter: 5_000)
            XCTAssertThrowsError(try replayed.bootstrap())
        }

        XCTAssertLessThan(abs(cleanBootstrapTime - replayBootstrapTime), 0.2)
    }

    func testBreachHandlingTimingConsistencyAcross100Attempts() throws {
        var timings: [TimeInterval] = []

        for i in 0..<100 {
            let store = makeLedgerStore(filename: "breach-timing-\(i)")
            let ledger = makeLedger(store: store, rollbackCounter: 0)

            try ledger.bootstrap()
            try ledger.append(request: "cmd", response: "ok")

            let t = try duration {
                _ = try ledger.handleSecurityEvent(.runtimeIntegrityFailure)
            }

            timings.append(t)
        }

        let maxTiming = timings.max() ?? 0
        let minTiming = timings.min() ?? 0

        XCTAssertLessThan(maxTiming - minTiming, 0.05)
    }

    func testValidationTimingCleanVsCorrupted10KChain() throws {
        let cleanStore = makeLedgerStore(filename: "validate-clean-10k")
        let corruptStore = makeLedgerStore(filename: "validate-corrupt-10k")

        let cleanLedger = makeLedger(store: cleanStore, rollbackCounter: 0)
        let corruptLedger = makeLedger(store: corruptStore, rollbackCounter: 0)

        try cleanLedger.bootstrap()
        try corruptLedger.bootstrap()

        for i in 0..<10_000 {
            try cleanLedger.append(request: "cmd\(i)", response: "ok\(i)")
            try corruptLedger.append(request: "cmd\(i)", response: "ok\(i)")
        }

        var corruptEntries = try corruptStore.load()
        corruptEntries[7_500] = LedgerEntry(
            rollbackCounter: corruptEntries[7_500].rollbackCounter,
            requestHash: String(repeating: "f", count: 64),
            responseHash: corruptEntries[7_500].responseHash,
            previousHash: corruptEntries[7_500].previousHash
        )
        try corruptStore.save(corruptEntries)

        let tClean = duration {
            XCTAssertNoThrow(try LedgerChainValidator.validate(cleanStore.load()))
        }

        let tCorrupt = duration {
            XCTAssertThrowsError(try LedgerChainValidator.validate(corruptStore.load()))
        }

        XCTAssertLessThan(abs(tClean - tCorrupt), 0.2)
    }
}
