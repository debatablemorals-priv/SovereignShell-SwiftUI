import XCTest
@testable import SovereignShell_SwiftUI

final class TerminalEngineTests: XCTestCase {
    @MainActor
    func testTerminalEngineInitializes() {
        let engine = TerminalEngine()
        XCTAssertNotNil(engine)
    }
}
