import SwiftUI

struct ThemeAuthority {
    static let terminalBackground = Color.black
    static let terminalText = Color.white
    static let terminalError = Color.red
    static let terminalSystem = Color.cyan

    static let toolbarBackground = Color.primary.opacity(0.06)

    static func color(for kind: TerminalOutputKind) -> Color {
        switch kind {
        case .command:
            return terminalText
        case .standard:
            return terminalText
        case .error:
            return terminalError
        case .system:
            return terminalSystem
        }
    }
}
