import Foundation
import CryptoKit

struct LedgerEntry: Codable {
    let entryID: UUID
    let timestamp: Date
    let rollbackCounter: Int
    let previousHash: String
    let requestHash: String
    let responseHash: String
    let envelopeHash: String
    
    func canonicalSerialization() -> String {
        return "\(entryID.uuidString)|\(timestamp.timeIntervalSince1970)|\(rollbackCounter)|\(requestHash)|\(responseHash)"
    }
}

class AISExecutionLedger {
    private var entries: [LedgerEntry] = []
    private var rollbackCounter: Int = 0
    private let fileURL: URL
    
    init() {
        self.fileURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("SovereignShell")
            .appendingPathComponent("ledger.chain")
        loadOrCreateLedger()
    }
    
    private func loadOrCreateLedger() {
        if FileManager.default.fileExists(atPath: fileURL.path) {
            loadLedger()
            verifyChainIntegrity()
        } else {
            createGenesisLedger()
        }
    }
    
    private func createGenesisLedger() {
        do {
            try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            let genesisEntry = LedgerEntry(
                entryID: UUID(),
                timestamp: Date(),
                rollbackCounter: 0,
                previousHash: "GENESIS",
                requestHash: computeHash("GENESIS_REQUEST"),
                responseHash: computeHash("GENESIS_RESPONSE"),
                envelopeHash: computeHash("GENESIS_ENVELOPE")
            )
            entries = [genesisEntry]
            rollbackCounter = 0
            saveLedger()
        } catch {
            fatalError("Failed to create genesis ledger: \(error)")
        }
    }
    
    private func loadLedger() {
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let loadedEntries = try decoder.decode([LedgerEntry].self, from: data)
            entries = loadedEntries
            rollbackCounter = entries.last?.rollbackCounter ?? 0
        } catch {
            fatalError("Failed to load ledger: \(error)")
        }
    }
    
    private func saveLedger() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(entries)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            fatalError("Failed to save ledger: \(error)")
        }
    }
    
    func append(_ requestHash: String, _ responseHash: String) throws {
        let newEntry = LedgerEntry(
            entryID: UUID(),
            timestamp: Date(),
            rollbackCounter: rollbackCounter + 1,
            previousHash: computeHash(entries.last?.canonicalSerialization() ?? "GENESIS"),
            requestHash: requestHash,
            responseHash: responseHash,
            envelopeHash: computeHash(requestHash + responseHash)
        )
        
        entries.append(newEntry)
        rollbackCounter += 1
        saveLedger()
    }
    
    private func verifyChainIntegrity() {
        for (index, entry) in entries.enumerated() {
            if index > 0 {
                let previousEntry = entries[index - 1]
                let expectedHash = computeHash(previousEntry.canonicalSerialization())
                guard expectedHash == entry.previousHash else {
                    fatalError("Chain integrity violation at entry \(index)")
                }
            }
        }
    }
    
    private func computeHash(_ input: String) -> String {
        let data = input.data(using: .utf8) ?? Data()
        let digest = SHA256.hash(data: data)
        return digest.withUnsafeBytes { ptr in
            ptr.map { String(format: "%02x", $0) }.joined()
        }
    }
    
    func getEntries() -> [LedgerEntry] {
        return entries
    }
    
    func getCurrentRollbackCounter() -> Int {
        return rollbackCounter
    }
}