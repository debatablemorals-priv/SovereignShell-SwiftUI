import Foundation
import CryptoKit

struct AISAttestationEnvelope: Codable, Equatable {
    let rollbackCounter: UInt64
    let timestamp: UInt64
    let operationClass: AISOperationClass
    let capabilityClass: AISCapabilityClass
    let handoffClass: AISHandoffClass
    let trustState: AISTrustState
    let policyVersion: AISPolicyVersion
    let ledgerDomain: AISLedgerDomain
    let bindingID: String
    let sandboxMeasurement: String
    let terminalMeasurement: String
    let previousHash: String
    let attestationHash: String

    init(
        rollbackCounter: UInt64,
        timestamp: UInt64,
        operationClass: AISOperationClass,
        capabilityClass: AISCapabilityClass,
        handoffClass: AISHandoffClass,
        trustState: AISTrustState,
        bindingID: String,
        sandboxMeasurement: String,
        terminalMeasurement: String,
        policyVersion: AISPolicyVersion,
        ledgerDomain: AISLedgerDomain,
        previousHash: String
    ) {
        self.rollbackCounter = rollbackCounter
        self.timestamp = timestamp
        self.operationClass = operationClass
        self.capabilityClass = capabilityClass
        self.handoffClass = handoffClass
        self.trustState = trustState
        self.bindingID = bindingID
        self.sandboxMeasurement = sandboxMeasurement
        self.terminalMeasurement = terminalMeasurement
        self.policyVersion = policyVersion
        self.ledgerDomain = ledgerDomain
        self.previousHash = previousHash
        self.attestationHash = Self.computeHash(
            rollbackCounter: rollbackCounter,
            timestamp: timestamp,
            operationClass: operationClass,
            capabilityClass: capabilityClass,
            handoffClass: handoffClass,
            trustState: trustState,
            bindingID: bindingID,
            sandboxMeasurement: sandboxMeasurement,
            terminalMeasurement: terminalMeasurement,
            policyVersion: policyVersion,
            ledgerDomain: ledgerDomain,
            previousHash: previousHash
        )
    }

    private static func computeHash(
        rollbackCounter: UInt64,
        timestamp: UInt64,
        operationClass: AISOperationClass,
        capabilityClass: AISCapabilityClass,
        handoffClass: AISHandoffClass,
        trustState: AISTrustState,
        bindingID: String,
        sandboxMeasurement: String,
        terminalMeasurement: String,
        policyVersion: AISPolicyVersion,
        ledgerDomain: AISLedgerDomain,
        previousHash: String
    ) -> String {
        let canonical = [
            String(rollbackCounter),
            String(timestamp),
            operationClass.rawValue,
            capabilityClass.rawValue,
            handoffClass.rawValue,
            trustState.rawValue,
            bindingID,
            sandboxMeasurement,
            terminalMeasurement,
            policyVersion.rawValue,
            ledgerDomain.rawValue,
            previousHash
        ].joined(separator: "|")

        let digest = SHA256.hash(data: Data(canonical.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
