import SwiftUI

struct TerminalView: View {
    @EnvironmentObject private var container: AppContainer

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
                ForEach(Array(container.terminalSession.outputLines), id: \.id) { line in
                    Text(verbatim: line.text)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(color(for: line.kind))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
        }
        .background(Color.black)
    }

    private func color(for kind: TerminalOutputKind) -> Color {
        switch kind {
        case .standard:
            return .green
        case .system:
            return .yellow
        case .success:
            return .blue
        case .error:
            return .red
        }
    }
}
