import Foundation

enum AISHandoffClass: String, Codable, Equatable {
    case none
    case transport
    case export
    case api
    case network
}
