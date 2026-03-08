import Foundation
import Combine

@MainActor
final class SecurityState: ObservableObject {
    @Published private(set) var isLocked: Bool
    @Published private(set) var isAISValid: Bool

    init(
        isLocked: Bool = false,
        isAISValid: Bool = false
    ) {
        self.isLocked = isLocked
        self.isAISValid = isAISValid
    }

    var canAcceptInput: Bool {
        !isLocked && isAISValid
    }

    func markAISValid() {
        isAISValid = true
    }

    func markAISInvalid() {
        isAISValid = false
        isLocked = true
    }

    func lock() {
        isLocked = true
    }

    func unlockIfTrusted() {
        guard isAISValid else {
            isLocked = true
            return
        }

        isLocked = false
    }

    func resetForTesting(
        isLocked: Bool = false,
        isAISValid: Bool = false
    ) {
        self.isLocked = isLocked
        self.isAISValid = isAISValid
    }
}
