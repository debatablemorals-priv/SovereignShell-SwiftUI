import XCTest
@testable import SovereignShell_SwiftUI

@MainActor
final class TerminalEngineTests: XCTestCase {
    func makeTempURL() -> URL {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)

        try! FileManager.default.createDirectory(
            at: dir,
            withIntermediateDirectories: true
        )

        return dir.appendingPathComponent("ledger.chain")
    }

    func makeEngine() throws -> (TerminalEngine, TerminalSession, SecurityState, LedgerStore) {
        let history = CommandHistory()
        let securityState = SecurityState()
        let session = TerminalSession()
        let logger = SecureLogger()
        let rollbackCounter = RollbackCounter(initialValue: 0)
        let store = LedgerStore(fileURL: makeTempURL())
        let ledger = AISExecutionLedger(
            store: store,
            logger: logger,
            initialRollbackCounter: 0
        )

        try ledger.bootstrap()

        let engine = TerminalEngine(
            router: CommandRouter(),
            session: session,
            history: history,
            securityState: securityState,
            rollbackCounter: rollbackCounter,
            executionLedger: ledger,
            logger: logger
        )

        return (engine, session, securityState, store)
    }

    func testExecuteCommandAppendsOutput() throws {
        let (engine, session, _, _) = try makeEngine()

        engine.execute("help")

        XCTAssertFalse(session.outputLines.isEmpty)
    }

    func testBootstrapWritesSystemMessages() throws {
        let (engine, session, _, _) = try makeEngine()

        engine.bootstrap()

        XCTAssertGreaterThanOrEqual(session.outputLines.count, 2)
    }
}
