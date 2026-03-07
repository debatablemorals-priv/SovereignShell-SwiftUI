import Foundation

extension AISExecutionLedger {

    func appendEvent(_ event: AISEvent) throws {
        let request = "AIS_EVENT:\(event.eventType.rawValue)"
        let response = "AIS_STATE:\(event.trustState.rawValue)"
        try append(request: request, response: response)
    }
}
