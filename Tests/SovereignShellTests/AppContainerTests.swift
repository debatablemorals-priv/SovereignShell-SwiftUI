import XCTest
@testable import SovereignShell_SwiftUI

@MainActor
final class AppContainerTests: XCTestCase {

    func testAppContainerInitializes() {
        let container = AppContainer()

        XCTAssertNotNil(container)
        XCTAssertNotNil(container.commandHistory)
        XCTAssertNotNil(container.securityState)
        XCTAssertNotNil(container.terminalSession)
        XCTAssertNotNil(container.terminalEngine)
    }

    func testTerminalSessionExistsAfterInitialization() {
        let container = AppContainer()

        XCTAssertFalse(container.terminalSession.outputLines.isEmpty)
    }
}
