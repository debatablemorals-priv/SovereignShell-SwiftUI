import XCTest
@testable import SovereignShell_SwiftUI

final class AISTrustEngineTests: XCTestCase {

    func testBootTransitionsUninitializedToTrusted() {
        let next = AISTrustEngine.nextState(
            current: .uninitialized,
            event: .boot
        )

        XCTAssertEqual(next, .trusted)
    }

    func testTransportReadyTransitionsTrustedToInTransit() {
        let next = AISTrustEngine.nextState(
            current: .trusted,
            event: .transportReady
        )

        XCTAssertEqual(next, .inTransit)
    }

    func testTransferInTransitionsInTransitToTrusted() {
        let next = AISTrustEngine.nextState(
            current: .inTransit,
            event: .transferIn
        )

        XCTAssertEqual(next, .trusted)
    }

    func testEraseFailedTransitionsToBroken() {
        let next = AISTrustEngine.nextState(
            current: .inTransit,
            event: .eraseFailed
        )

        XCTAssertEqual(next, .broken)
    }

    func testTrustBrokenAlwaysTransitionsToBroken() {
        let next = AISTrustEngine.nextState(
            current: .trusted,
            event: .trustBroken
        )

        XCTAssertEqual(next, .broken)
    }

    func testBrokenStateRemainsBroken() {
        let next = AISTrustEngine.nextState(
            current: .broken,
            event: .transferIn
        )

        XCTAssertEqual(next, .broken)
    }
}
