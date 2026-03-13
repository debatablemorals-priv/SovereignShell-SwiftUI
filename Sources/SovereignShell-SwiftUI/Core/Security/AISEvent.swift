import Foundation

struct AISEvent: Equatable {
    let rollbackCounter: UInt64
    let timestamp: UInt64
    let eventType: AISEventType
    let trustState: AISTrustState
    let handoffClass: AISHandoffClass
    let previousHash: String
    let envelopeHash: String?
    let operationClass: AISOperationClass?
    let capabilityClass: AISCapabilityClass?
    let policyVersion: AISPolicyVersion?
    let ledgerDomain: AISLedgerDomain?
    let bindingID: String?
    let sandboxMeasurement: String?
    let terminalMeasurement: String?
    let attestationHash: String?

    init(
        rollbackCounter: UInt64,
        timestamp: UInt64,
        eventType: AISEventType,
        trustState: AISTrustState,
        handoffClass: AISHandoffClass,
        previousHash: String,
        envelopeHash: String? = nil,
        operationClass: AISOperationClass? = nil,
        capabilityClass: AISCapabilityClass? = nil,
        policyVersion: AISPolicyVersion? = nil,
        ledgerDomain: AISLedgerDomain? = nil,
        bindingID: String? = nil,
        sandboxMeasurement: String? = nil,
        terminalMeasurement: String? = nil,
        attestationHash: String? = nil
    ) {
        self.rollbackCounter = rollbackCounter
        self.timestamp = timestamp
        self.eventType = eventType
        self.trustState = trustState
        self.handoffClass = handoffClass
        self.previousHash = previousHash
        self.envelopeHash = envelopeHash
        self.operationClass = operationClass
        self.capabilityClass = capabilityClass
        self.policyVersion = policyVersion
        self.ledgerDomain = ledgerDomain
        self.bindingID = bindingID
        self.sandboxMeasurement = sandboxMeasurement
        self.terminalMeasurement = terminalMeasurement
        self.attestationHash = attestationHash
    }
}
