import Foundation

enum AISTrustState: String, Codable, Equatable {
    case uninitialized
    case trusted
    case inTransit
    case locked
    case broken
    case erased
}
