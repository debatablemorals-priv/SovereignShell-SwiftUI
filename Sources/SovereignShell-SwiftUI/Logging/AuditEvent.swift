import Foundation

public struct AuditEvent: Codable, Identifiable {

    public enum Level: String, Codable {
        case info
        case warning
        case error
        case security
    }

    public let id: UUID
    public let timestamp: Date
    public let level: Level
    public let message: String

    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        level: Level,
        message: String
    ) {
        self.id = id
        self.timestamp = timestamp
        self.level = level
        self.message = message
    }
}
