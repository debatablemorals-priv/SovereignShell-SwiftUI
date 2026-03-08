import XCTest
@testable import SovereignShell_SwiftUI

@MainActor
final class CISmokeTests: XCTestCase {
    func testAppContainerInitializes() throws {
        _ = try AppContainer()
    }

    func testTerminalSessionInitializes() {
        let session = TerminalSession()
        XCTAssertNotNil(session)
    }

    func testCommandHistoryStartsEmpty() {
        let history = CommandHistory()
        XCTAssertEqual(history.entries.count, 0)
    }
}
