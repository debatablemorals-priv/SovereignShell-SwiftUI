import Foundation
import CryptoKit

extension LedgerEntry {
    init(event: AISEvent) {
        self.init(
            rollbackCounter: event.rollbackCounter,
            requestHash: Self.hash(
                [
                    event.eventType.rawValue,
                    event.operationClass?.rawValue ?? "",
                    event.bindingID ?? "",
                    event.sandboxMeasurement ?? ""
                ].joined(separator: "|")
            ),
            responseHash: Self.hash(
                [
                    event.trustState.rawValue,
                    event.handoffClass.rawValue,
                    event.capabilityClass?.rawValue ?? "",
                    event.terminalMeasurement ?? ""
                ].joined(separator: "|")
            ),
            previousHash: event.previousHash,
            eventTypeRaw: event.eventType.rawValue,
            trustStateRaw: event.trustState.rawValue,
            handoffClassRaw: event.handoffClass.rawValue,
            operationClassRaw: event.operationClass?.rawValue,
            capabilityClassRaw: event.capabilityClass?.rawValue,
            policyVersion: event.policyVersion?.rawValue,
            ledgerDomain: event.ledgerDomain?.rawValue,
            bindingID: event.bindingID,
            sandboxMeasurement: event.sandboxMeasurement,
            terminalMeasurement: event.terminalMeasurement,
            attestationHash: event.attestationHash
        )
    }

    func asAISEvent() -> AISEvent {
        AISEvent(
            rollbackCounter: rollbackCounter,
            timestamp: UInt64(max(0, Int64(timestamp.timeIntervalSince1970))),
            eventType: AISEventType(rawValue: eventTypeRaw ?? "") ?? .command,
            trustState: AISTrustState(rawValue: trustStateRaw ?? "") ?? .trusted,
            handoffClass: AISHandoffClass(rawValue: handoffClassRaw ?? "") ?? .none,
            previousHash: previousHash,
            envelopeHash: envelopeHash,
            operationClass: operationClassRaw.flatMap(AISOperationClass.init(rawValue:)),
            capabilityClass: capabilityClassRaw.flatMap(AISCapabilityClass.init(rawValue:)),
            policyVersion: policyVersion.flatMap(AISPolicyVersion.init(rawValue:)),
            ledgerDomain: ledgerDomain.flatMap(AISLedgerDomain.init(rawValue:)),
            bindingID: bindingID,
            sandboxMeasurement: sandboxMeasurement,
            terminalMeasurement: terminalMeasurement,
            attestationHash: attestationHash
        )
    }

    private static func hash(_ value: String) -> String {
        let data = Data(value.utf8)
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
