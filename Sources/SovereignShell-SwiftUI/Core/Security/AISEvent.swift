import Foundation

struct AISEvent: Codable, Equatable {
    let rollbackCounter: UInt64
    let timestamp: UInt64
    let eventType: AISEventType
    let trustState: AISTrustState
    let handoffClass: AISHandoffClass
    let previousHash: String

    init(
        rollbackCounter: UInt64,
        timestamp: UInt64,
        eventType: AISEventType,
        trustState: AISTrustState,
        handoffClass: AISHandoffClass,
        previousHash: String
    ) {
        self.rollbackCounter = rollbackCounter
        self.timestamp = timestamp
        self.eventType = eventType
        self.trustState = trustState
        self.handoffClass = handoffClass
        self.previousHash = previousHash
    }
}
