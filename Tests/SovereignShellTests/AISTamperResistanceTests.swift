import XCTest
@testable import SovereignShell_SwiftUI

final class AISTamperResistanceTests: XCTestCase {

    func makeTempURL() -> URL {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("ledger.chain")
    }

    func testCorruptedLedgerFailsBootstrap() throws {
        let url = makeTempURL()
        try Data("not-json".utf8).write(to: url)

        let store = LedgerStore(fileURL: url)
        let logger = SecureLogger()
        let ledger = AISExecutionLedger(
            store: store,
            logger: logger,
            initialRollbackCounter: 0
        )

        XCTAssertThrowsError(try ledger.bootstrap())
    }

    func testRollbackMismatchFailsVerification() throws {
        let url = makeTempURL()
        let store = LedgerStore(fileURL: url)
        let logger = SecureLogger()

        let ledger = AISExecutionLedger(
            store: store,
            logger: logger,
            initialRollbackCounter: 4
        )

        try ledger.bootstrap()

        XCTAssertThrowsError(
            try ledger.verifyAgainstRollbackCounter(999)
        ) { error in
            XCTAssertEqual(error as? LedgerError, .rollbackViolation)
        }
    }
}
