import Foundation

public final class LedgerStore {

    private let fileURL: URL

    public init(fileURL: URL) {
        self.fileURL = fileURL
    }

    public func load() throws -> [LedgerEntry] {

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw LedgerError.ledgerNotFound
        }

        let data = try Data(contentsOf: fileURL)

        return try JSONDecoder().decode([LedgerEntry].self, from: data)
    }

    public func save(_ entries: [LedgerEntry]) throws {

        let data = try JSONEncoder().encode(entries)

        try data.write(to: fileURL, options: .atomic)
    }
}
