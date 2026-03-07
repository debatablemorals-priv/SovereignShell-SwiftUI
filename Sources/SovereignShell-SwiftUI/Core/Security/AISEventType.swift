import Foundation

enum AISEventType: String, Codable, Equatable {
    case boot
    case command
    case unseal
    case internalHandoff
    case transportReady
    case transferOut
    case transferIn
    case lock
    case erase
    case eraseFailed
    case trustBroken
}
