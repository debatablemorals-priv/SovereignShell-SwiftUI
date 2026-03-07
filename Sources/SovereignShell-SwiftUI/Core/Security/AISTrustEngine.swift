import Foundation

struct AISTrustEngine {

    static func nextState(
        current: AISTrustState,
        event: AISEventType
    ) -> AISTrustState {

        switch (current, event) {

        case (.trusted, .transport):
            return .inTransit

        case (.inTransit, .handoff):
            return .trusted

        case (.trusted, .tamperDetected):
            return .broken

        case (.inTransit, .tamperDetected):
            return .broken

        case (.trusted, .trustBroken):
            return .broken

        case (.broken, _):
            return .broken

        default:
            return current
        }
    }
}
