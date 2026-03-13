import Foundation
import Combine

@MainActor
final class TerminalEngine: ObservableObject {
    private let router: CommandRouter
    private let session: TerminalSession
    private let history: CommandHistory
    private let securityState: SecurityState
    private let rollbackCounter: RollbackCounter
    private let executionLedger: AISExecutionLedger
    private let logger: SecureLogger

    init(
        router: CommandRouter,
        session: TerminalSession,
        history: CommandHistory,
        securityState: SecurityState,
        rollbackCounter: RollbackCounter,
        executionLedger: AISExecutionLedger,
        logger: SecureLogger
    ) {
        self.router = router
        self.session = session
        self.history = history
        self.securityState = securityState
        self.rollbackCounter = rollbackCounter
        self.executionLedger = executionLedger
        self.logger = logger
    }

    var terminalSession: TerminalSession {
        session
    }

    func execute(_ rawInput: String) {
        let trimmed = rawInput.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            logger.warning("Rejected empty command.")
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

        history.add(trimmed)
        session.appendCommandEcho(trimmed)

        do {
            let result = try router.route(
                trimmed,
                securityState: securityState
            )

            let responseForLedger = result.output ?? "[NO_OUTPUT]"

            try executionLedger.append(
                request: trimmed,
                response: responseForLedger
            )

            try syncRollbackCounterFromLedger()

            logger.security("Ledger commit succeeded for command: \(trimmed)")

            if result.shouldClearBeforeRender {
                session.clear()
            }

            if result.shouldLockSystem {
                securityState.lock()
                session.lock()
            }

            if let output = result.output, !output.isEmpty {
                session.appendOutput(output, kind: .standard)
            }

        } catch let error as LedgerError {
            logger.security("AIS ledger failure detected for command: \(trimmed)")

            do {
                let disposition = try executionLedger.handleSecurityEvent(.ledgerCorruption)

                do {
                    try syncRollbackCounterFromLedger()
                } catch {
                    logger.security("Rollback counter sync failed after AIS security event.")
                }

                securityState.markAISInvalid()
                session.lock()

                session.appendOutput(
                    "AIS SECURITY EVENT — TRUST DOMAIN LOCKED",
                    kind: .error
                )

                session.appendOutput(
                    "Secret disposition: \(disposition)",
                    kind: .error
                )

                session.appendOutput(
                    String(describing: error),
                    kind: .error
                )
            } catch {
                logger.security("AIS breach handling failed.")
                session.lock()
                securityState.markAISInvalid()
            }

        } catch let error as ExecutionError {
            logger.error("Execution routing failed for command: \(trimmed)")
            session.appendOutput(String(describing: error), kind: .error)

        } catch {
            logger.error("Unexpected execution failure for command: \(trimmed)")
           session.appendOutput("UNEXPECTED EXECUTION FAILURE", kind: .error)
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
        logger.security("Terminal engine activated after deterministic boot validation.")
    }

    private func syncRollbackCounterFromLedger() throws {
        let ledgerValue = executionLedger.currentRollbackCounter()

        guard ledgerValue <= UInt64(Int.max) else {
            throw LedgerError.rollbackViolation
        }

        try rollbackCounter.commit(Int(ledgerValue))
    }
}
