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

        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode([LedgerEntry].self, from: data)
        } catch {
            throw LedgerError.corruptedLedger
        }
    }

    public func save(_ entries: [LedgerEntry]) throws {
        do {
            let directoryURL = fileURL.deletingLastPathComponent()

            try FileManager.default.createDirectory(
                at: directoryURL,
                withIntermediateDirectories: true
            )

            let data = try JSONEncoder().encode(entries)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            throw LedgerError.persistenceFailure
        }
    }
}
