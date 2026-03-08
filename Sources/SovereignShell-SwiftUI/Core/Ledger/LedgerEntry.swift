import Foundation
import CryptoKit

public struct LedgerEntry: Codable, Identifiable {
    public let id: UUID
    public let timestamp: Date
    public let rollbackCounter: UInt64
    public let requestHash: String
    public let responseHash: String
    public let previousHash: String
    public let envelopeHash: String

    public let eventTypeRaw: String?
    public let trustStateRaw: String?
    public let handoffClassRaw: String?
    public let operationClassRaw: String?
    public let capabilityClassRaw: String?
    public let policyVersion: String?
    public let ledgerDomain: String?
    public let bindingID: String?
    public let sandboxMeasurement: String?
    public let terminalMeasurement: String?
    public let attestationHash: String?

    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        rollbackCounter: UInt64,
        requestHash: String,
        responseHash: String,
        previousHash: String,
        eventTypeRaw: String? = nil,
        trustStateRaw: String? = nil,
        handoffClassRaw: String? = nil,
        operationClassRaw: String? = nil,
        capabilityClassRaw: String? = nil,
        policyVersion: String? = nil,
        ledgerDomain: String? = nil,
        bindingID: String? = nil,
        sandboxMeasurement: String? = nil,
        terminalMeasurement: String? = nil,
        attestationHash: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.rollbackCounter = rollbackCounter
        self.requestHash = requestHash
        self.responseHash = responseHash
        self.previousHash = previousHash
        self.eventTypeRaw = eventTypeRaw
        self.trustStateRaw = trustStateRaw
        self.handoffClassRaw = handoffClassRaw
        self.operationClassRaw = operationClassRaw
        self.capabilityClassRaw = capabilityClassRaw
        self.policyVersion = policyVersion
        self.ledgerDomain = ledgerDomain
        self.bindingID = bindingID
        self.sandboxMeasurement = sandboxMeasurement
        self.terminalMeasurement = terminalMeasurement
        self.attestationHash = attestationHash

        self.envelopeHash = Self.computeEnvelopeHash(
            rollbackCounter: rollbackCounter,
            requestHash: requestHash,
            responseHash: responseHash,
            previousHash: previousHash,
            eventTypeRaw: eventTypeRaw,
            trustStateRaw: trustStateRaw,
            handoffClassRaw: handoffClassRaw,
            operationClassRaw: operationClassRaw,
            capabilityClassRaw: capabilityClassRaw,
            policyVersion: policyVersion,
            ledgerDomain: ledgerDomain,
            bindingID: bindingID,
            sandboxMeasurement: sandboxMeasurement,
            terminalMeasurement: terminalMeasurement,
            attestationHash: attestationHash
        )
    }

    static func computeEnvelopeHash(
        rollbackCounter: UInt64,
        requestHash: String,
        responseHash: String,
        previousHash: String,
        eventTypeRaw: String? = nil,
        trustStateRaw: String? = nil,
        handoffClassRaw: String? = nil,
        operationClassRaw: String? = nil,
        capabilityClassRaw: String? = nil,
        policyVersion: String? = nil,
        ledgerDomain: String? = nil,
        bindingID: String? = nil,
        sandboxMeasurement: String? = nil,
        terminalMeasurement: String? = nil,
        attestationHash: String? = nil
    ) -> String {
        var components: [String] = []
        components.append(String(rollbackCounter))
        components.append(requestHash)
        components.append(responseHash)
        components.append(previousHash)
        components.append(eventTypeRaw ?? "")
        components.append(trustStateRaw ?? "")
        components.append(handoffClassRaw ?? "")
        components.append(operationClassRaw ?? "")
        components.append(capabilityClassRaw ?? "")
        components.append(policyVersion ?? "")
         components.append(ledgerDomain ?? "")
        components.append(bindingID ?? "")
        components.append(sandboxMeasurement ?? "")
        components.append(terminalMeasurement ?? "")
        components.append(attestationHash ?? "")

        let canonical = components.joined(separator: "|")
        let digest = SHA256.hash(data: Data(canonical.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
