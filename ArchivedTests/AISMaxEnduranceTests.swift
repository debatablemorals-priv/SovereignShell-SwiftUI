import XCTest
@testable import SovereignShell_SwiftUI

final class AISMaxEnduranceTests: XCTestCase {

    private func makeLedgerStore(filename: String = UUID().uuidString) -> LedgerStore {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("AISMaxEnduranceTests", isDirectory: true)

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

    func testSequentialEventFlood250000() throws {
        let store = makeLedgerStore(filename: "sequential-250000")
        let ledger = makeLedger(store: store, rollbackCounter: 0)

        try ledger.bootstrap()

        for i in 0..<250_000 {
            try ledger.append(request: "cmd\(i)", response: "ok\(i)")
        }

        let entries = try store.load()

        XCTAssertEqual(entries.count, 250_001) // genesis + 250k
        XCTAssertEqual(entries.last?.rollbackCounter, 250_000)
        XCTAssertNoThrow(try LedgerChainValidator.validate(entries))
    }
}
