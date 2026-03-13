import Foundation

/// AISBreachDetector converts integrity failures into deterministic
/// AIS security outcomes.
///
/// AIS remains passive during normal operation.
/// When a breach condition is detected, this type classifies the event
/// and defines the required trust-state and secret-disposition response.

struct AISBreachDetector {

    static func trustState(for event: AISSecurityEvent) -> AISTrustState {
        switch event {
        case .ledgerCorruption,
             .rollbackViolation,
             .invalidTrustTransition,
             .runtimeIntegrityFailure,
             .trustBoundaryBreach,
             .eraseFailure:
            return .broken
        }
    }

    static func disposition(for event: AISSecurityEvent) -> AISSecretDisposition {
        switch event {
        case .ledgerCorruption,
             .rollbackViolation,
             .invalidTrustTransition,
             .runtimeIntegrityFailure,
             .trustBoundaryBreach:
            return .locked

        case .eraseFailure:
            return .eraseFailed
        }
    }

    static func eventType(for event: AISSecurityEvent) -> AISEventType {
        switch event {
        case .ledgerCorruption,
             .rollbackViolation,
             .invalidTrustTransition,
             .runtimeIntegrityFailure,
             .trustBoundaryBreach:
            return .trustBroken

        case .eraseFailure:
            return .eraseFailed
        }
    }
}
