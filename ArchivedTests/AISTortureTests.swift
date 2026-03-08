import XCTest
@testable import SovereignShell_SwiftUI

final class AISTortureTests: XCTestCase {

    private func makeLedgerStore(filename: String = UUID().uuidString) -> LedgerStore {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("AISTortureTests", isDirectory: true)

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

    func testSequentialEventFlood10000() throws {
        let store = makeLedgerStore(filename: "sequential-10000")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()

        for i in 0..<10_000 {
            try ledger.append(request: "cmd\(i)", response: "ok\(i)")
        }

        let entries = try store.load()
        XCTAssertEqual(entries.count, 10_001) // genesis + 10k
        XCTAssertEqual(entries.last?.rollbackCounter, 10_000)
        XCTAssertNoThrow(try LedgerChainValidator.validate(entries))
    }

    func testValidationAfter10000Events() throws {
        let store = makeLedgerStore(filename: "validate-10000")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()

        for i in 0..<10_000 {
            try ledger.append(request: "cmd\(i)", response: "ok\(i)")
        }

        measure {
            do {
                let entries = try store.load()
                try LedgerChainValidator.validate(entries)
            } catch {
                XCTFail("Validation failed after 10k events: \(error)")
            }
        }
    }

    func testConcurrentEventFlood500() throws {
        let store = makeLedgerStore(filename: "concurrent-500")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()

        let lock = NSLock()
        var errors: [Error] = []

        DispatchQueue.concurrentPerform(iterations: 500) { i in
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
        XCTAssertEqual(entries.count, 501) // genesis + 500
        XCTAssertNoThrow(try LedgerChainValidator.validate(entries))
    }

    func testReplayAttackSimulationRejected() throws {
        let store = makeLedgerStore(filename: "replay-attack")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()

        for i in 0..<20 {
            try ledger.append(request: "cmd\(i)", response: "ok\(i)")
        }

        let originalEntries = try store.load()
        XCTAssertEqual(originalEntries.count, 21)

        // Replay an older state by truncating to an earlier valid prefix.
        let replayedEntries = Array(originalEntries.prefix(10))
        try store.save(replayedEntries)

        XCTAssertThrowsError(
            try ledger.verifyAgainstRollbackCounter(20)
        ) { error in
            XCTAssertEqual(error as? LedgerError, .rollbackViolation)
        }
    }

    func testTimestampMonotonicitySanityUnderSequentialLoad() throws {
        let store = makeLedgerStore(filename: "timestamp-sanity")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()

        for i in 0..<250 {
            try ledger.append(request: "cmd\(i)", response: "ok\(i)")
        }

        let disposition = try ledger.handleSecurityEvent(.runtimeIntegrityFailure)

        XCTAssertEqual(disposition, .locked)
        XCTAssertTrue(ledger.lockedState())

        XCTAssertThrowsError(
            try ledger.append(request: "after-breach", response: "denied")
        )
    }
}
