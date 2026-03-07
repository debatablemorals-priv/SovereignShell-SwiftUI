import Foundation

public struct LogSanitizer {

    public static func sanitize(_ message: String) -> String {

        var sanitized = message

        sanitized = sanitized.replacingOccurrences(of: "\n", with: " ")
        sanitized = sanitized.replacingOccurrences(of: "\r", with: " ")

        if sanitized.count > 500 {
            sanitized = String(sanitized.prefix(500))
        }

        return sanitized
    }
}
