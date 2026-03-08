import Foundation
import Combine

@MainActor
final class TerminalSession: ObservableObject {
    @Published private(set) var lines: [TerminalLine]
    @Published private(set) var isLocked: Bool

    private let maxBufferLines: Int

    init(
        lines: [TerminalLine] = [],
        isLocked: Bool = false,
        maxBufferLines: Int = 500
    ) {
        self.lines = lines
        self.isLocked = isLocked
        self.maxBufferLines = max(100, maxBufferLines)
    }

    func appendCommandEcho(_ command: String) {
        guard !isLocked else {
            return
        }

        appendLine(
            TerminalLine(
                text: "$ \(command)",
                kind: .command
            )
        )
    }

    func appendOutput(_ output: String, kind: TerminalOutputKind) {
        let normalized = output.replacingOccurrences(of: "\r\n", with: "\n")
        let splitLines = normalized.components(separatedBy: "\n")

        if splitLines.isEmpty {
            appendLine(TerminalLine(text: "", kind: kind))
            return
        }

        for line in splitLines {
            appendLine(
                TerminalLine(
                    text: line,
                    kind: kind
                )
            )
        }
    }

    func clear() {
        guard !isLocked else {
            return
        }

        lines.removeAll(keepingCapacity: true)
    }

    func lock() {
        isLocked = true
    }

    func unlockForTesting() {
        isLocked = false
    }

    func resetForTesting() {
        lines.removeAll(keepingCapacity: true)
        isLocked = false
    }

    private func appendLine(_ line: TerminalLine) {
        lines.append(line)

        if lines.count > maxBufferLines {
            let overflow = lines.count - maxBufferLines
            lines.removeFirst(overflow)
        }
    }
}

struct TerminalLine: Identifiable, Equatable {
    let id: UUID
    let text: String
    let kind: TerminalOutputKind

    init(
        id: UUID = UUID(),
        text: String,
        kind: TerminalOutputKind
    ) {
        self.id = id
        self.text = text
        self.kind = kind
    }
}
