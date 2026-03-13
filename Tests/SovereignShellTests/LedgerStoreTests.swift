import XCTest
@testable import SovereignShell_SwiftUI

final class LedgerStoreTests: XCTestCase {

    func makeTempURL() -> URL {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("ledger.chain")
    }

    func makeEntry(counter: UInt64) -> LedgerEntry {
        LedgerEntry(
            rollbackCounter: counter,
            requestHash: String(repeating: "a", count: 64),
            responseHash: String(repeating: "b", count: 64),
            previousHash: String(repeating: "0", count: 64)
        )
    }

    func testSaveAndLoadRoundTrip() throws {
        let url = makeTempURL()
        let store = LedgerStore(fileURL: url)

        let entries = [
            makeEntry(counter: 0),
            makeEntry(counter: 1)
        ]

        try store.save(entries)

        let loaded = try store.load()

        XCTAssertEqual(loaded.count, 2)
        XCTAssertEqual(loaded[0].rollbackCounter, 0)
        XCTAssertEqual(loaded[1].rollbackCounter, 1)
    }

    func testMissingFileThrowsLedgerNotFound() {
        let url = makeTempURL()
        let store = LedgerStore(fileURL: url)

        XCTAssertThrowsError(try store.load()) { error in
            XCTAssertEqual(error as? LedgerError, .ledgerNotFound)
        }
    }
}
