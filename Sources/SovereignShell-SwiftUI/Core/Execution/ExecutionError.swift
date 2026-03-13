import Foundation

public enum ExecutionError: Error {
    case emptyCommand(raw: String)
    case locked(reason: String)
    case routingFailed(command: String, reason: String)
    case ledgerCommitFailed(command: String, reason: String)
}
