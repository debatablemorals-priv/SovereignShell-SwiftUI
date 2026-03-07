import Foundation

public struct ExecutionResult {
    public let shouldClearBeforeRender: Bool
    public let output: String?
    public let shouldLockSystem: Bool

    public init(
        shouldClearBeforeRender: Bool = false,
        output: String? = nil,
        shouldLockSystem: Bool = false
    ) {
        self.shouldClearBeforeRender = shouldClearBeforeRender
        self.output = output
        self.shouldLockSystem = shouldLockSystem
    }
}
