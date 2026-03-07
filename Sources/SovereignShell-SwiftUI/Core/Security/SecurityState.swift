import Foundation
import Combine

@MainActor
final class SecurityState: ObservableObject {
    @Published private(set) var isLocked: Bool
    @Published private(set) var isAISValid: Bool
    @Published private(set) var isOAuthValid: Bool
    @Published private(set) var runtimeViolationDetected: Bool

    init(
        isLocked: Bool = false,
        isAISValid: Bool = true,
        isOAuthValid: Bool = false,
        runtimeViolationDetected: Bool = false
    ) {
        self.isLocked = isLocked
        self.isAISValid = isAISValid
        self.isOAuthValid = isOAuthValid
        self.runtimeViolationDetected = runtimeViolationDetected
    }

    func lock() {
        isLocked = true
    }

    func unlock() {
        guard isAISValid && !runtimeViolationDetected else { return }
        isLocked = false
    }

    func markAISInvalid() {
        isAISValid = false
        isLocked = true
    }

    func markAISValid() {
        isAISValid = true
    }

    func markOAuthValid() {
        isOAuthValid = true
    }

    func markOAuthInvalid() {
        isOAuthValid = false
    }

    func markRuntimeViolation() {
        runtimeViolationDetected = true
        isLocked = true
    }

    func clearRuntimeViolation() {
        runtimeViolationDetected = false
    }

    var canAcceptInput: Bool {
        isAISValid && !isLocked && !runtimeViolationDetected
    }
}