import Foundation

struct AISTrustEngine {

    /// Deterministic trust-state transition function.
    /// Any unrecognized transition MUST fail closed at the call site if strict enforcement is desired.
    static func nextState(
        current: AISTrustState,
        event: AISEventType
    ) -> AISTrustState {

        // Once broken/erased/locked, we do not return to trusted automatically.
        switch current {
        case .broken:
            return .broken
        case .erased:
            return .erased
        case .locked:
            // Locked stays locked unless you later add an explicit recovery event.
            return .locked
        case .uninitialized, .trusted, .inTransit:
            break
        }

        switch (current, event) {

        // Boot establishes initial trust.
        case (.uninitialized, .boot):
            return .trusted

        // Normal trusted operation (no trust-state change).
        case (.trusted, .command),
             (.trusted, .unseal),
             (.trusted, .internalHandoff):
            return .trusted

        // Transition to in-transit when preparing to cross a boundary.
        case (.trusted, .transportReady),
             (.trusted, .transferOut):
            return .inTransit

        // In-transit can continue exporting or be received back into trusted domain.
        case (.inTransit, .transferOut):
            return .inTransit

        case (.inTransit, .transferIn):
            return .trusted

        // Lock can occur from trusted or in-transit.
        case (.trusted, .lock),
             (.inTransit, .lock):
            return .locked

        // Erase is a terminal success state (only meaningful once in transit).
        case (.inTransit, .erase):
            return .erased

        // Erase failure breaks trust.
        case (.trusted, .eraseFailed),
             (.inTransit, .eraseFailed):
            return .broken

        // Explicit trust break always breaks.
        case (_, .trustBroken):
            return .broken

        // Default: preserve current state (caller may choose to treat as invalid).
        default:
            return current
        }
    }
}
