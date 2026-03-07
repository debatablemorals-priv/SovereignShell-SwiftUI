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

    func advance() {
        value += 1
    }

    func validateMonotonicProgression(_ incoming: Int) throws {
        guard incoming >= value else {
            throw RollbackCounterError.rollbackDetected(
                expectedMinimum: value,
                received: incoming
            )
        }
    }

    func commit(_ newValue: Int) throws {
        try validateMonotonicProgression(newValue)
        value = newValue
    }
}

enum RollbackCounterError: Error, Equatable {
    case rollbackDetected(expectedMinimum: Int, received: Int)
}