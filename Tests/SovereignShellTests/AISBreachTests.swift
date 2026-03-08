import XCTest
@testable import SovereignShell_SwiftUI

final class AISBreachTests: XCTestCase {

    func testBreachLocksAIS() throws {

        let store = LedgerStore(
            fileURL: FileManager.default.temporaryDirectory
                .appendingPathComponent("ais-breach.chain")
        )

        let ledger = AISExecutionLedger(
            store: store,
            logger: SecureLogger(),
            initialRollbackCounter: 0
        )

        try ledger.bootstrap()

        let disposition = try ledger.handleSecurityEvent(.ledgerCorruption)

        XCTAssertEqual(disposition, .locked)

        XCTAssertTrue(ledger.lockedState())

        XCTAssertThrowsError(
            try ledger.append(request: "cmd", response: "should fail")
        )
    }
}
