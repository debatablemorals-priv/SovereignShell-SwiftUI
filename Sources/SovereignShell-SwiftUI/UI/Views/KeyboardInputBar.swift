import SwiftUI

struct KeyboardInputBar: View {
    @EnvironmentObject private var container: AppContainer
    @State private var commandText: String = ""

<<<<<<< HEAD
    private var isInputBlocked: Bool {
        !container.securityState.canAcceptInput || container.terminalSession.isLocked
    }

    var body: some View {
        HStack(spacing: 12) {
            TextField(inputPlaceholder, text: $commandText)
                .textFieldStyle(.roundedBorder)
                .disabled(isInputBlocked)
=======
    var body: some View {
        HStack(spacing: 12) {
            TextField("Enter command", text: $commandText)
                .textFieldStyle(.roundedBorder)
>>>>>>> 5c5b4ce6485bb529c03a391a80b9c2e16233dd29
                .onSubmit {
                    executeCommand()
                }

            Button("Run") {
                executeCommand()
            }
<<<<<<< HEAD
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
        guard !isInputBlocked else { return }
        let trimmed = commandText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        commandText = ""
        container.terminalEngine.execute(trimmed)
=======
            .buttonStyle(.borderedProminent)
            .disabled(commandText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
    }

    private func executeCommand() {
        let trimmed = commandText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        container.terminalEngine.execute(trimmed)
        commandText = ""
>>>>>>> 5c5b4ce6485bb529c03a391a80b9c2e16233dd29
    }
}
