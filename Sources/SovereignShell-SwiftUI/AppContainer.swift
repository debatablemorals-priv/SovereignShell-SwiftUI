import Foundation
import Combine

@MainActor
final class AppContainer: ObservableObject {
    let commandHistory: CommandHistory
    let securityState: SecurityState
    let rollbackCounter: RollbackCounter
    let logger: SecureLogger
    let executionLedger: AISExecutionLedger
    let terminalSession: TerminalSession
    let terminalEngine: TerminalEngine

    init() {
        self.commandHistory = CommandHistory()
        self.securityState = SecurityState()
        self.rollbackCounter = RollbackCounter()
        self.logger = SecureLogger()
        self.terminalSession = TerminalSession()

        let applicationSupportURL = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0]

        let ledgerURL = applicationSupportURL
            .appendingPathComponent("Security", isDirectory: true)
            .appendingPathComponent("ledger.chain", isDirectory: false)

        let ledgerStore = LedgerStore(fileURL: ledgerURL)

        self.executionLedger = AISExecutionLedger(
            store: ledgerStore,
            logger: logger,
            initialRollbackCounter: UInt64(rollbackCounter.current())
        )

        self.terminalEngine = TerminalEngine(
            router: CommandRouter(),
            session: terminalSession,
            history: commandHistory,
            securityState: securityState,
            executionLedger: executionLedger,
            logger: logger
        )

        do {
            try executionLedger.bootstrap()
            try executionLedger.verifyAgainstRollbackCounter(
                UInt64(rollbackCounter.current())
            )

            securityState.markAISValid()
            logger.security("Deterministic boot sequence completed successfully.")
            terminalEngine.bootstrap()
        } catch {
            securityState.markAISInvalid()
            logger.security("Deterministic boot sequence failed. Terminal activation blocked.")
            terminalSession.appendOutput(
                "AIS verification failed. Execution halted.",
                kind: .error
            )
        }
    }
}
