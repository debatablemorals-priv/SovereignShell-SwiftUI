import Foundation

extension AISExecutionLedger {

    func appendEvent(_ event: AISEvent) throws {
        try append(event: event)
    }

}
