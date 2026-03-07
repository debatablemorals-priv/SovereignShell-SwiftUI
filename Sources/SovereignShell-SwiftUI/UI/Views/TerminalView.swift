import SwiftUI

struct TerminalView: View {
    @EnvironmentObject private var container: AppContainer

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(container.terminalSession.outputLines) { line in
                        Text(line.text)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(color(for: line.kind))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .id(line.id)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            .background(Color.black)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .onAppear {
                scrollToBottom(with: proxy)
            }
            .onChange(of: container.terminalSession.outputLines.count) { _ in
                scrollToBottom(with: proxy)
            }
        }
    }

    private func scrollToBottom(with proxy: ScrollViewProxy) {
        guard let lastID = container.terminalSession.outputLines.last?.id else {
            return
        }

        proxy.scrollTo(lastID, anchor: .bottom)
    }

    private func color(for kind: TerminalOutputKind) -> Color {
        switch kind {
        case .standard:
            return .white
        case .command:
            return .white
        case .success:
            return .cyan
        case .error:
            return .red
        case .system:
            return .gray
        }
    }
}