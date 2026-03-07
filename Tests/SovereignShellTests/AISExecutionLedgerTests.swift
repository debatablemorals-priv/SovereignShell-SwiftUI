import XCTest
@testable import SovereignShell_SwiftUI

final class AISExecutionLedgerTests: XCTestCase {

    func makeTempURL() -> URL {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("ledger.chain")
    }

    func makeLedger(counter: UInt64) -> (AISExecutionLedger, LedgerStore) {
        let url = makeTempURL()
        let store = LedgerStore(fileURL: url)
        let logger = SecureLogger()

        let ledger = AISExecutionLedger(
            store: store,
            logger: logger,
            initialRollbackCounter: counter
        )

        return (ledger, store)
    }

    func testBootstrapCreatesGenesis() throws {
        let (ledger, store) = makeLedger(counter: 5)

        try ledger.bootstrap()

        let entries = try store.load()

        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries[0].rollbackCounter, 5)
        XCTAssertEqual(entries[0].previousHash, String(repeating: "0", count: 64))
    }

    func testAppendCreatesSecondEntry() throws {
        let (ledger, store) = makeLedger(counter: 1)

        try ledger.bootstrap()
        try ledger.append(request: "help", response: "ok")

        let entries = try store.load()

        XCTAssertEqual(entries.count, 2)
        XCTAssertEqual(entries[1].rollbackCounter, 2)
        XCTAssertEqual(entries[1].previousHash, entries[0].envelopeHash)
    }

    func testRollbackMismatchThrows() throws {
        let (ledger, _) = makeLedger(counter: 3)

        try ledger.bootstrap()

        XCTAssertThrowsError(
            try ledger.verifyAgainstRollbackCounter(999)
        ) { error in
            XCTAssertEqual(error as? LedgerError, .rollbackViolation)
        }
    }
}
