import XCTest
@testable import SovereignShell_SwiftUI

final class AISCrashRecoveryTests: XCTestCase {

    func testCorruptedLedgerDetection() throws {

        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("ais-corrupt.chain")

        let store = LedgerStore(fileURL: fileURL)

        let ledger = AISExecutionLedger(
            store: store,
            logger: SecureLogger(),
            initialRollbackCounter: 0
        )

        try ledger.bootstrap()
        try ledger.append(request: "cmd", response: "ok")

        var data = try Data(contentsOf: fileURL)

        data.append("CORRUPTION".data(using: .utf8)!)

        try data.write(to: fileURL)

        XCTAssertThrowsError(
            try LedgerChainValidator.validate(store.load())
        )
    }
}
