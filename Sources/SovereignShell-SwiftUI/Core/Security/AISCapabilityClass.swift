import Foundation

enum AISCapabilityClass: String, Codable, Equatable {
    case none
    case secureEnclaveExport
    case keychainRelease
    case sessionHandle
    case apiAuthorization
}
