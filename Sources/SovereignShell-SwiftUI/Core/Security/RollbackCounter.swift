import Foundation
import Combine

@MainActor
final class RollbackCounter: ObservableObject {
    @Published private(set) var value: Int

    init(initialValue: Int = 0) {
        self.value = max(0, initialValue)
    }

    func current() -> Int {
        value
    }

    func commit(_ newValue: Int) throws {
        guard newValue >= 0 else {
            throw LedgerError.rollbackViolation
        }

        guard newValue >= value else {
            throw LedgerError.rollbackViolation
        }

        value = newValue
    }

    func advance() throws {
        guard value < Int.max else {
            throw LedgerError.rollbackViolation
        }

        value += 1
    }

    func resetForTesting(to newValue: Int = 0) {
        value = max(0, newValue)
    }
}
