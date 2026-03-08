import XCTest
@testable import SovereignShell_SwiftUI

final class CISmokeTests: XCTestCase {
    @MainActor
    func testAppContainerInitializes() {
        let container = AppContainer()
        XCTAssertNotNil(container)
    }

    @MainActor
    func testCommandHistoryInitializes() {
        let history = CommandHistory()
        XCTAssertNotNil(history)
    }
}
