import Foundation
import CryptoKit

struct AISEvent: Codable, Equatable {
    let rollbackCounter: UInt64
    let timestamp: UInt64
    let eventType: AISEventType
    let trustState: AISTrustState
    let handoffClass: AISHandoffClass
    let previousHash: String
    let envelopeHash: String

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
        self.operationClass = operationClass
        self.capabilityClass = capabilityClass
        self.policyVersion = policyVersion
        self.ledgerDomain = ledgerDomain
        self.bindingID = bindingID
        self.sandboxMeasurement = sandboxMeasurement
        self.terminalMeasurement = terminalMeasurement

        let derivedAttestationHash = attestationHash ?? Self.computeAttestationHash(
            rollbackCounter: rollbackCounter,
            timestamp: timestamp,
            eventType: eventType,
            trustState: trustState,
            handoffClass: handoffClass,
            previousHash: previousHash,
            operationClass: operationClass,
            capabilityClass: capabilityClass,
            policyVersion: policyVersion,
            ledgerDomain: ledgerDomain,
            bindingID: bindingID,
            sandboxMeasurement: sandboxMeasurement,
            terminalMeasurement: terminalMeasurement
        )

        self.attestationHash = derivedAttestationHash

        self.envelopeHash = envelopeHash ?? Self.computeEnvelopeHash(
            rollbackCounter: rollbackCounter,
            timestamp: timestamp,
            eventType: eventType,
            trustState: trustState,
            handoffClass: handoffClass,
            previousHash: previousHash,
            attestationHash: derivedAttestationHash
        )
    }

    private static func computeAttestationHash(
        rollbackCounter: UInt64,
        timestamp: UInt64,
        eventType: AISEventType,
        trustState: AISTrustState,
        handoffClass: AISHandoffClass,
        previousHash: String,
        operationClass: AISOperationClass?,
        capabilityClass: AISCapabilityClass?,
        policyVersion: AISPolicyVersion?,
        ledgerDomain: AISLedgerDomain?,
        bindingID: String?,
        sandboxMeasurement: String?,
        terminalMeasurement: String?
    ) -> String {
        var components: [String] = []
        components.append(String(rollbackCounter))
        components.append(String(timestamp))
        components.append(eventType.rawValue)
        components.append(trustState.rawValue)
        components.append(handoffClass.rawValue)
        components.append(previousHash)
        components.append(operationClass?.rawValue ?? "")
        components.append(capabilityClass?.rawValue ?? "")
        components.append(policyVersion?.rawValue ?? "")
        components.append(ledgerDomain?.rawValue ?? "")
        components.append(bindingID ?? "")
        components.append(sandboxMeasurement ?? "")
        components.append(terminalMeasurement ?? "")

        let canonical = components.joined(separator: "|")
        let digest = SHA256.hash(data: Data(canonical.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private static func computeEnvelopeHash(
        rollbackCounter: UInt64,
        timestamp: UInt64,
        eventType: AISEventType,
        trustState: AISTrustState,
        handoffClass: AISHandoffClass,
        previousHash: String,
        attestationHash: String
    ) -> String {
        var components: [String] = []
        components.append(String(rollbackCounter))
        components.append(String(timestamp))
        components.append(eventType.rawValue)
        components.append(trustState.rawValue)
        components.append(handoffClass.rawValue)
        components.append(previousHash)
        components.append(attestationHash)

        let canonical = components.joined(separator: "|")
        let digest = SHA256.hash(data: Data(canonical.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
