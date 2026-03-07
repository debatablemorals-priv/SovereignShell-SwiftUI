import Foundation
import Combine

@MainActor
final class AppContainer: ObservableObject {
    let commandHistory: CommandHistory
    let securityState: SecurityState
    let rollbackCounter: RollbackCounter
    let executionLedger: AISExecutionLedger
    let terminalSession: TerminalSession
    let terminalEngine: TerminalEngine

    init() {
        self.commandHistory = CommandHistory()
        self.securityState = SecurityState()
        self.rollbackCounter = RollbackCounter()
        self.executionLedger = AISExecutionLedger()
        self.terminalSession = TerminalSession()
        self.terminalEngine = TerminalEngine(
            session: terminalSession,
            history: commandHistory,
            securityState: securityState
        )

        self.terminalEngine.bootstrap()
    }
}