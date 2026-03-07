import Foundation

enum CommandRouterError: Error, Equatable {
    case emptyCommand
    case unknownCommand(command: String)
}

struct CommandRouter {
    func route(
        _ rawInput: String,
        session: TerminalSession,
        history: CommandHistory,
        securityState: SecurityState
    ) throws {
        let trimmed = rawInput.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            throw CommandRouterError.emptyCommand
        }

        history.add(trimmed)
        session.appendCommandEcho(trimmed)

        let components = parse(trimmed)
        guard let command = components.first?.lowercased() else {
            throw CommandRouterError.emptyCommand
        }

        let arguments = Array(components.dropFirst())

        switch command {
        case "help":
            handleHelp(session: session)

        case "echo":
            handleEcho(arguments: arguments, session: session)

        case "clear":
            handleClear(session: session)

        case "lock":
            handleLock(session: session, securityState: securityState)

        default:
            throw CommandRouterError.unknownCommand(command: command)
        }
    }

    private func parse(_ input: String) -> [String] {
        input
            .split(whereSeparator: { $0.isWhitespace })
            .map(String.init)
    }

    private func handleHelp(session: TerminalSession) {
        session.appendOutput("Available commands:", kind: .system)
        session.appendOutput("  help  - Show available commands", kind: .standard)
        session.appendOutput("  echo  - Echo arguments back to the terminal", kind: .standard)
        session.appendOutput("  clear - Clear terminal output", kind: .standard)
        session.appendOutput("  lock  - Lock the session", kind: .standard)
    }

    private func handleEcho(arguments: [String], session: TerminalSession) {
        let output = arguments.joined(separator: " ")
        session.appendOutput(output, kind: .standard)
    }

    private func handleClear(session: TerminalSession) {
        session.clear()
    }

    private func handleLock(session: TerminalSession, securityState: SecurityState) {
        securityState.lock()
        session.lock()
        session.appendOutput("Session locked.", kind: .system)
    }
}