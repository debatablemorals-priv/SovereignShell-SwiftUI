import Foundation

public final class SecureLogger: ObservableObject {

    @Published public private(set) var events: [AuditEvent] = []

    public init() {}

    public func log(level: AuditEvent.Level, message: String) {

        let sanitized = LogSanitizer.sanitize(message)

        let event = AuditEvent(
            level: level,
            message: sanitized
        )

        DispatchQueue.main.async {
            self.events.append(event)
        }
    }

    public func info(_ message: String) {
        log(level: .info, message: message)
    }

    public func warning(_ message: String) {
        log(level: .warning, message: message)
    }

    public func error(_ message: String) {
        log(level: .error, message: message)
    }

    public func security(_ message: String) {
        log(level: .security, message: message)
    }
}
