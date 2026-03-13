import Foundation

final class LedgerStore {
    let fileURL: URL
    private let fileManager: FileManager

    init(
        fileURL: URL,
        fileManager: FileManager = .default
    ) {
        self.fileURL = fileURL.standardizedFileURL
        self.fileManager = fileManager
    }

    func load() throws -> [LedgerEntry] {
        guard fileManager.fileExists(atPath: fileURL.path) else {
            throw LedgerError.ledgerNotFound
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            return try decoder.decode([LedgerEntry].self, from: data)
        } catch let error as LedgerError {
            throw error
        } catch {
            throw LedgerError.corruptedLedger
        }
    }

    func save(_ entries: [LedgerEntry]) throws {
        do {
            try ensureParentDirectoryExists()

            let encoder = JSONEncoder()
            if #available(iOS 11.0, macOS 10.13, *) {
                encoder.outputFormatting = [.sortedKeys]
            }

            let data = try encoder.encode(entries)
            try data.write(to: fileURL, options: .atomic)
            try applyPostWriteProtections()
        } catch let error as LedgerError {
            throw error
        } catch {
            throw LedgerError.persistenceFailure
        }
    }

    private func ensureParentDirectoryExists() throws {
        let directoryURL = fileURL.deletingLastPathComponent()

        if !fileManager.fileExists(atPath: directoryURL.path) {
            try fileManager.createDirectory(
                at: directoryURL,
                withIntermediateDirectories: true
            )
        }

        var directoryValues = URLResourceValues()
        directoryValues.isExcludedFromBackup = true

        var mutableDirectoryURL = directoryURL
        try mutableDirectoryURL.setResourceValues(directoryValues)
    }

    private func applyPostWriteProtections() throws {
        var fileValues = URLResourceValues()
        fileValues.isExcludedFromBackup = true

        var mutableFileURL = fileURL
        try mutableFileURL.setResourceValues(fileValues)

        #if os(iOS)
        try fileManager.setAttributes(
            [.protectionKey: FileProtectionType.complete],
            ofItemAtPath: fileURL.path
        )
        #endif
    }
}
