import Foundation
import Combine

@MainActor
final class TerminalEngine: ObservableObject {
    private let router: CommandRouter
    private let session: TerminalSession
    private let history: CommandHistory
    private let securityState: SecurityState

    init(
        router: CommandRouter,
        session: TerminalSession,
        history: CommandHistory,
        securityState: SecurityState
    ) {
        self.router = router
        self.session = session
        self.history = history
        self.securityState = securityState
    }

    var terminalSession: TerminalSession {
        session
    }

    func execute(_ rawInput: String) {
        let trimmed = rawInput.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            return
        }

        guard securityState.canAcceptInput else {
            session.appendOutput(
                "Execution blocked: terminal input is unavailable.",
                kind: .error
            )
            return
        }

        guard !session.isLocked else {
            session.appendOutput(
                "Execution blocked: session is locked.",
                kind: .error
            )
            return
        }

        do {
            try router.route(
                trimmed,
                session: session,
                history: history,
                securityState: securityState
            )
        } catch let error as CommandRouterError {
            handleRouterError(error)
        } catch {
            session.appendOutput(
                "Execution failed due to an unexpected terminal error.",
                kind: .error
            )
        }
    }

    func bootstrap() {
        session.appendOutput(
            "SovereignShell terminal initialized.",
            kind: .system
        )
        session.appendOutput(
            "Type 'help' to view available commands.",
            kind: .system
        )
    }

    private func handleRouterError(_ error: CommandRouterError) {
        switch error {
        case .emptyCommand:
            break

        case .unknownCommand(let command):
            session.appendOutput(
                "Unknown command: \(command)",
                kind: .error
            )
            session.appendOutput(
                "Type 'help' to view available commands.",
                kind: .system
            )
        }
    }
}
