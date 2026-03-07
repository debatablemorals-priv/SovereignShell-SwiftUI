import XCTest
@testable import SovereignShell_SwiftUI

final class AISEventBridgeTests: XCTestCase {

    func testLedgerEntryBridgesToAISEvent() {
        let entry = LedgerEntry(
            rollbackCounter: 7,
            requestHash: String(repeating: "a", count: 64),
            responseHash: String(repeating: "b", count: 64),
            previousHash: String(repeating: "0", count: 64)
        )

        let event = entry.asAISEvent()

        XCTAssertEqual(event.rollbackCounter, 7)
        XCTAssertEqual(event.eventType, .command)
        XCTAssertEqual(event.trustState, .trusted)
        XCTAssertEqual(event.previousHash, String(repeating: "0", count: 64))
    }
}
