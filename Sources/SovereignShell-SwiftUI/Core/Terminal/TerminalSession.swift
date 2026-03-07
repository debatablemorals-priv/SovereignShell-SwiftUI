import Foundation
import Combine

@MainActor
final class TerminalSession: ObservableObject {
    @Published private(set) var outputLines: [TerminalOutputLine]
    @Published private(set) var currentPrompt: String
    @Published private(set) var isLocked: Bool
    @Published private(set) var sessionIdentifier: UUID

    init(
        outputLines: [TerminalOutputLine] = [],
        currentPrompt: String = ">",
        isLocked: Bool = false,
        sessionIdentifier: UUID = UUID()
    ) {
        self.outputLines = outputLines
        self.currentPrompt = currentPrompt
        self.isLocked = isLocked
        self.sessionIdentifier = sessionIdentifier
    }

    func appendOutput(_ text: String, kind: TerminalOutputKind = .standard) {
        let trimmed = text.trimmingCharacters(in: .newlines)
        guard !trimmed.isEmpty else { return }

        outputLines.append(
            TerminalOutputLine(
                text: trimmed,
                kind: kind,
                timestamp: Date()
            )
        )
    }

    func appendCommandEcho(_ command: String) {
        let trimmed = command.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        outputLines.append(
            TerminalOutputLine(
                text: "\(currentPrompt) \(trimmed)",
                kind: .command,
                timestamp: Date()
            )
        )
    }

    func clear() {
        outputLines.removeAll(keepingCapacity: false)
    }

    func lock() {
        isLocked = true
    }

    func unlock() {
        isLocked = false
    }

    func updatePrompt(_ prompt: String) {
        let trimmed = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        currentPrompt = trimmed
    }

    func resetSession() {
        outputLines.removeAll(keepingCapacity: false)
        currentPrompt = ">"
        isLocked = false
        sessionIdentifier = UUID()
    }
}

struct TerminalOutputLine: Identifiable, Equatable {
    let id: UUID
    let text: String
    let kind: TerminalOutputKind
    let timestamp: Date

    init(
        id: UUID = UUID(),
        text: String,
        kind: TerminalOutputKind,
        timestamp: Date
    ) {
        self.id = id
        self.text = text
        self.kind = kind
        self.timestamp = timestamp
    }
}

enum TerminalOutputKind: Equatable {
    case standard
    case command
    case success
    case error
    case system
}