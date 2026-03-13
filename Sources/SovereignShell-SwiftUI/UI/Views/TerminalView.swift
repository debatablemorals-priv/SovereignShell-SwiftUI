import SwiftUI

struct TerminalView: View {
    @EnvironmentObject private var container: AppContainer

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(container.terminalSession.outputLines) { line in
                        Text(verbatim: line.text)
                            .font(.system(.body, design: .monospaced))
                            .foregroundStyle(color(for: line.kind))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .id(line.id)
                    }
                }
                .padding()
            }
            .background(Color.black)
            .onAppear {
                scrollToBottom(using: proxy)
            }
            .onChange(of: container.terminalSession.outputLines.count) { _ in
                scrollToBottom(using: proxy)
            }
        }
    }

    private func color(for kind: TerminalOutputKind) -> Color {
        switch kind {
        case .command:
            return .white
        case .standard:
            return .white
        case .error:
            return .red
        case .system:
            return .cyan
        }
    }

    private func scrollToBottom(using proxy: ScrollViewProxy) {
        guard let lastID = container.terminalSession.outputLines.last?.id else {
            return
        }

        DispatchQueue.main.async {
            proxy.scrollTo(lastID, anchor: .bottom)
        }
    }
}
