import SwiftUI

struct KeyboardInputBar: View {
    @EnvironmentObject private var container: AppContainer
    @State private var commandText: String = ""

    private var isInputBlocked: Bool {
        !container.securityState.canAcceptInput || container.terminalSession.isLocked
    }

    var body: some View {
        HStack(spacing: 12) {
            TextField(inputPlaceholder, text: $commandText)
                .textFieldStyle(.roundedBorder)
                .disabled(isInputBlocked)
                .onReceive(NotificationCenter.default.publisher(for: NSTextField.textDidEndEditingNotification)) { _ in
                    guard !isInputBlocked else { return }
                }

            Button("Run") {
                executeCommand()
            }
            .disabled(isInputBlocked || commandText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
        .background(.thinMaterial)
    }

    private var inputPlaceholder: String {
        if !container.securityState.isAISValid {
            return "AIS invalid — input blocked"
        }

        if container.terminalSession.isLocked || container.securityState.isLocked {
            return "Session locked"
        }

        return "Enter command"
    }

    private func executeCommand() {
        guard !isInputBlocked else {
            return
        }

        let trimmed = commandText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return
        }

        commandText = ""
        container.terminalEngine.execute(trimmed)
    }
}
