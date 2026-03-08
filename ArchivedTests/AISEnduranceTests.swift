import XCTest
@testable import SovereignShell_SwiftUI

final class AISEnduranceTests: XCTestCase {

    private func makeLedgerStore(filename: String = UUID().uuidString) -> LedgerStore {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("AISEnduranceTests", isDirectory: true)

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

    func testSequentialEventFlood50000() throws {
        let store = makeLedgerStore(filename: "sequential-50000")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()

        for i in 0..<50_000 {
            try ledger.append(request: "cmd\(i)", response: "ok\(i)")
        }

        let entries = try store.load()
        XCTAssertEqual(entries.count, 50_001) // genesis + 50k
        XCTAssertEqual(entries.last?.rollbackCounter, 50_000)
        XCTAssertNoThrow(try LedgerChainValidator.validate(entries))
    }

    func testValidationAfter50000Events() throws {
        let store = makeLedgerStore(filename: "validate-50000")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()

        for i in 0..<50_000 {
            try ledger.append(request: "cmd\(i)", response: "ok\(i)")
        }

        let entries = try store.load()
        XCTAssertEqual(entries.count, 50_001)

        XCTAssertNoThrow(try LedgerChainValidator.validate(entries))
    }

    func testBreachAfter50000EventsStillLocks() throws {
        let store = makeLedgerStore(filename: "breach-after-50000")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()

        for i in 0..<50_000 {
            try ledger.append(request: "cmd\(i)", response: "ok\(i)")
        }

        let disposition = try ledger.handleSecurityEvent(.runtimeIntegrityFailure)

        XCTAssertEqual(disposition, .locked)
        XCTAssertTrue(ledger.lockedState())

        XCTAssertThrowsError(
            try ledger.append(request: "after-breach", response: "denied")
        )
    }

    func testReplayAttackRejectedAfter50000Events() throws {
        let store = makeLedgerStore(filename: "replay-after-50000")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()

        for i in 0..<50_000 {
            try ledger.append(request: "cmd\(i)", response: "ok\(i)")
        }

        let originalEntries = try store.load()
        XCTAssertEqual(originalEntries.count, 50_001)

        let replayedEntries = Array(originalEntries.prefix(25_000))
        try store.save(replayedEntries)

        XCTAssertThrowsError(
            try ledger.verifyAgainstRollbackCounter(50_000)
        ) { error in
            XCTAssertEqual(error as? LedgerError, .rollbackViolation)
        }
    }
}
