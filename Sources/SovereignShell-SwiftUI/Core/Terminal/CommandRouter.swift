import Foundation

final class CommandRouter {

    func route(
        _ rawCommand: String,
        securityState: SecurityState
    ) throws -> ExecutionResult {
        let parts = parse(rawCommand)

        guard let command = parts.first else {
            throw ExecutionError.emptyCommand(raw: rawCommand)
        }

        let arguments = Array(parts.dropFirst())

        switch command {
        case "help":
            return ExecutionResult(
                output: """
Available commands:
  help  - Show this help message
  echo  - Echo text back to the terminal
  clear - Clear terminal output
  lock  - Lock the terminal
"""
            )

        case "echo":
            return ExecutionResult(
                output: arguments.joined(separator: " ")
            )

        case "clear":
            return ExecutionResult(
                shouldClearBeforeRender: true,
                output: nil
            )

        case "lock":
            return ExecutionResult(
                output: "SYSTEM LOCK ENGAGED",
                shouldLockSystem: true
            )

        default:
            throw ExecutionError.routingFailed(
                command: command,
                reason: "Unknown command"
            )
        }
    }

    private func parse(_ input: String) -> [String] {
        input
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(whereSeparator: \.isWhitespace)
            .map(String.init)
    }
}
