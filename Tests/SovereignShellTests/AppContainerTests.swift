import XCTest
@testable import SovereignShell_SwiftUI

final class AppContainerTests: XCTestCase {
    @MainActor
    func testAppContainerInitializes() {
        let container = AppContainer()
        XCTAssertNotNil(container)
    }
}
