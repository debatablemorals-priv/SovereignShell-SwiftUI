import XCTest
@testable import SovereignShell_SwiftUI

final class TerminalEngineTests: XCTestCase {
    @MainActor
    func testTerminalEngineInitializes() {
        let logger = SecureLogger(subsystem: "SovereignShellTests", category: "TerminalEngineTests")
        let session = TerminalSession()
        let history = CommandHistory()
        let securityState = SecurityState()
        let rollbackCounter = RollbackCounter()
        let ledgerStore = LedgerStore()
        let executionLedger = AISExecutionLedger(store: ledgerStore, logger: logger)
        let router = CommandRouter()

        let engine = TerminalEngine(
            router: router,
            session: session,
            history: history,
            securityState: securityState,
            rollbackCounter: rollbackCounter,
            executionLedger: executionLedger,
            logger: logger
        )

        XCTAssertNotNil(engine)
    }
}
