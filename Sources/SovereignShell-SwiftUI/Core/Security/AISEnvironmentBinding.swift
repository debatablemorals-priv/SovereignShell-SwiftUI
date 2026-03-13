import Foundation

struct AISEnvironmentBinding: Codable, Equatable {
    let bindingDigest: String
    let bindingID: AISBindingID
    let measurement: AISRuntimeMeasurement
    let policyVersion: AISPolicyVersion
    let ledgerDomain: AISLedgerDomain

    init(
        rootAnchor: AISRootAnchor,
        measurement: AISRuntimeMeasurement,
        policyVersion: AISPolicyVersion,
        ledgerDomain: AISLedgerDomain
    ) {
        self.measurement = measurement
        self.policyVersion = policyVersion
        self.ledgerDomain = ledgerDomain

        let digest = rootAnchor.childDigest(
            measurement: measurement,
            policyVersion: policyVersion,
            ledgerDomain: ledgerDomain
        )
        self.bindingDigest = digest

        let truncated = Self.truncatedDigestData(fromHex: digest, byteCount: 20)
        self.bindingID = AISBindingID(truncatedDigest: truncated)
    }

    private static func truncatedDigestData(fromHex hex: String, byteCount: Int) -> Data {
        var bytes: [UInt8] = []
        bytes.reserveCapacity(hex.count / 2)

        var index = hex.startIndex
        while index < hex.endIndex {
            let nextIndex = hex.index(index, offsetBy: 2)
            let byteString = hex[index..<nextIndex]
            if let value = UInt8(byteString, radix: 16) {
                bytes.append(value)
            }
            index = nextIndex
        }

        return Data(bytes.prefix(byteCount))
    }
}
