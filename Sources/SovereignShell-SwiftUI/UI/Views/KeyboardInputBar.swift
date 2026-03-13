import SwiftUI

struct KeyboardInputBar: View {
    @EnvironmentObject private var container: AppContainer
    @State private var commandText: String = ""

    var body: some View {
        HStack(spacing: 12) {
            TextField("Enter command", text: $commandText)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    executeCommand()
                }

            Button("Run") {
                executeCommand()
            }
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
    }
}
