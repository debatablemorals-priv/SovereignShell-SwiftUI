import Foundation
import Combine

@MainActor
final class CommandHistory: ObservableObject {
    @Published private(set) var commands: [String]

    init(commands: [String] = []) {
        self.commands = commands
    }

    func add(_ command: String) {
        let trimmed = command.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        commands.append(trimmed)
    }

    func recent(limit: Int) -> [String] {
        guard limit > 0 else { return [] }
        return Array(commands.suffix(limit))
    }

    func clear() {
        commands.removeAll(keepingCapacity: false)
    }

    func mostRecent() -> String? {
        commands.last
    }
}