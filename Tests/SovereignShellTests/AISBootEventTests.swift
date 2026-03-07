import XCTest
@testable import SovereignShell_SwiftUI

final class AISBootEventTests: XCTestCase {

    func testBootEventTransitionsTrustState() {
        let event = AISEventFactory.bootEvent(
            rollbackCounter: 0,
            previousHash: String(repeating: "0", count: 64)
        )

        let next = AISTrustEngine.nextState(
            current: .uninitialized,
            event: event.eventType
        )

        XCTAssertEqual(next, .trusted)
    }
}
