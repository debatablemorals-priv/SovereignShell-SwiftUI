import Foundation

struct AISBindingID: Codable, Equatable, CustomStringConvertible {
    let rawValue: String

    var description: String { rawValue }

    init(rawValue: String) {
        self.rawValue = rawValue
    }

    init(truncatedDigest data: Data) {
        self.rawValue = Self.base58Encode(data)
    }

    private static func base58Encode(_ data: Data) -> String {
        guard !data.isEmpty else { return "" }

        let alphabet = Array("123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz")
        var bytes = Array(data)
        var zeroCount = 0

        while zeroCount < bytes.count && bytes[zeroCount] == 0 {
            zeroCount += 1
        }

        var encoded: [Character] = []
        var startAt = zeroCount

        while startAt < bytes.count {
            var remainder = 0
            for index in startAt..<bytes.count {
                let value = Int(bytes[index]) & 0xff
                let accumulator = remainder * 256 + value
                bytes[index] = UInt8(accumulator / 58)
                remainder = accumulator % 58
            }

            encoded.append(alphabet[remainder])

            while startAt < bytes.count && bytes[startAt] == 0 {
                startAt += 1
            }
        }

        for _ in 0..<zeroCount {
            encoded.append("1")
        }

        return String(encoded.reversed())
    }
}
