import SwiftUI

struct TerminalView: View {

    @EnvironmentObject private var container: AppContainer

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 4) {
                ForEach(container.terminalSession.lines) { line in
                    Text(line.text)
                        .foregroundColor(color(for: line.kind))
                        .font(ThemeAuthority.font)
                }
            }
            .padding()
        }
        .background(ThemeAuthority.background)
    }

    private func color(for kind: TerminalLine.Kind) -> Color {
        switch kind {
        case .input:
            return ThemeAuthority.accent
        case .output:
            return ThemeAuthority.terminalText
        case .system:
            return ThemeAuthority.warning
        case .error:
            return ThemeAuthority.error
        }
    }
}
