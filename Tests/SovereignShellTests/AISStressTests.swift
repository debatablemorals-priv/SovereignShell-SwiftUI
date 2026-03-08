import XCTest
@testable import SovereignShell_SwiftUI

final class AISStressTests: XCTestCase {

    private func makeLedgerStore(filename: String = UUID().uuidString) -> LedgerStore {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("AISStressTests", isDirectory: true)

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

    func testSequentialEventFlood1000() throws {
        let store = makeLedgerStore(filename: "sequential-1000")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()

        for i in 0..<1000 {
            try ledger.append(request: "cmd\(i)", response: "ok\(i)")
        }

        let entries = try store.load()
        XCTAssertEqual(entries.count, 1001) // genesis + 1000
        XCTAssertEqual(entries.last?.rollbackCounter, 1000)
    }

    func testSequentialValidationAfter1000Events() throws {
        let store = makeLedgerStore(filename: "validate-1000")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()

        for i in 0..<1000 {
            try ledger.append(request: "cmd\(i)", response: "ok\(i)")
        }

        let entries = try store.load()
        XCTAssertNoThrow(try LedgerChainValidator.validate(entries))
    }

    func testConcurrentEventFlood100() throws {
        let store = makeLedgerStore(filename: "concurrent-100")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()

        let lock = NSLock()
        var errors: [Error] = []

        DispatchQueue.concurrentPerform(iterations: 100) { i in
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
        XCTAssertEqual(entries.count, 101) // genesis + 100
        XCTAssertNoThrow(try LedgerChainValidator.validate(entries))
    }

    func testHandoffFlood100() throws {
        let store = makeLedgerStore(filename: "handoff-100")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()

        for i in 0..<100 {
            let result: AISTrustHandoff.Result = (i % 10 == 0) ? .failed : .attested
            try AISTrustHandoff.record(
                result: result,
                handoffClass: .network,
                ledger: ledger
            )
        }

        let entries = try store.load()
        XCTAssertEqual(entries.count, 101)
        XCTAssertNoThrow(try LedgerChainValidator.validate(entries))
    }

    func testBreachUnderLoadLocksImmediately() throws {
        let store = makeLedgerStore(filename: "breach-under-load")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()

        for i in 0..<200 {
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
