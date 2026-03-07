import SwiftUI

struct KeyboardInputBar: View {
    @EnvironmentObject private var container: AppContainer
    @State private var commandText: String = ""

    var body: some View {
        let isInputBlocked = !container.securityState.canAcceptInput || container.terminalSession.isLocked
        let trimmedCommand = commandText.trimmingCharacters(in: .whitespacesAndNewlines)

        HStack(spacing: 10) {
            Text(container.terminalSession.currentPrompt)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(isInputBlocked ? .gray : .white)
                .frame(width: 16, alignment: .leading)

            TextField("Enter command...", text: $commandText)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(isInputBlocked ? .gray : .white)
                .textFieldStyle(.plain)
                .disabled(isInputBlocked)
                .submitLabel(.go)
                .onSubmit {
                    executeCommand()
                }

            Button(action: executeCommand) {
                Text("Execute")
                    .font(.system(.caption, design: .monospaced))
                    .fontWeight(.semibold)
                    .foregroundColor(isInputBlocked ? .gray : .white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(isInputBlocked ? 0.04 : 0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            .disabled(isInputBlocked || trimmedCommand.isEmpty)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(red: 0.07, green: 0.07, blue: 0.09))
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1),
            alignment: .top
        )
    }

    private func executeCommand() {
        let trimmed = commandText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        container.terminalEngine.execute(trimmed)
        commandText = ""
    }
}