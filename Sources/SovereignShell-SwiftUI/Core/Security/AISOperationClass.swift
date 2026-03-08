import Foundation

enum AISOperationClass: String, Codable, Equatable {
    case boot
    case commandExecution
    case securityEvent
    case internalHandoff
    case apiHandoff
    case transport
    case export
    case attestation
}
