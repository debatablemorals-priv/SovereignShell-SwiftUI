import XCTest
@testable import SovereignShell_SwiftUI

final class AISConcurrencyTests: XCTestCase {

    func testConcurrentLedgerWrites() throws {

        let store = LedgerStore(
            fileURL: FileManager.default.temporaryDirectory
                .appendingPathComponent("ais-concurrency.chain")
        )

        let ledger = AISExecutionLedger(
            store: store,
            logger: SecureLogger(),
            initialRollbackCounter: 0
        )

        try ledger.bootstrap()

        let expectation = XCTestExpectation(description: "Concurrent writes complete")
        expectation.expectedFulfillmentCount = 20

        DispatchQueue.concurrentPerform(iterations: 20) { i in
            do {
                try ledger.append(
                    request: "cmd\(i)",
                    response: "ok"
                )
            } catch {
                XCTFail("Ledger write failed: \(error)")
            }

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)

        let entries = try store.load()

        XCTAssertEqual(entries.count, 21) // 1 genesis + 20 writes
    }
}
