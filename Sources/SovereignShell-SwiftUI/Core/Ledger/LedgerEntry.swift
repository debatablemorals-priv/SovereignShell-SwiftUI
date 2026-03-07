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

    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        rollbackCounter: UInt64,
        requestHash: String,
        responseHash: String,
        previousHash: String
    ) {
        self.id = id
        self.timestamp = timestamp
        self.rollbackCounter = rollbackCounter
        self.requestHash = requestHash
        self.responseHash = responseHash
        self.previousHash = previousHash
        self.envelopeHash = LedgerEntry.computeEnvelopeHash(
            id: id,
            timestamp: timestamp,
            rollbackCounter: rollbackCounter,
            requestHash: requestHash,
            responseHash: responseHash,
            previousHash: previousHash
        )
    }

    private static func computeEnvelopeHash(
        id: UUID,
        timestamp: Date,
        rollbackCounter: UInt64,
        requestHash: String,
        responseHash: String,
        previousHash: String
    ) -> String {

        let payload =
        "\(id.uuidString)|\(timestamp.timeIntervalSince1970)|\(rollbackCounter)|\(requestHash)|\(responseHash)|\(previousHash)"

        let digest = SHA256.hash(data: Data(payload.utf8))

        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
