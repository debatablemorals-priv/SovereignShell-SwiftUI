import SwiftUI

struct KeyboardInputBar: View {

    @EnvironmentObject private var container: AppContainer
    @State private var commandText: String = ""

    var body: some View {
        HStack {

            TextField("Enter command", text: $commandText)
                .font(ThemeAuthority.font)
                .foregroundColor(ThemeAuthority.terminalText)

            Button("Run") {
                executeCommand()
            }
            .foregroundColor(ThemeAuthority.accent)
        }
        .padding(8)
        .background(ThemeAuthority.background)
    }

    private func executeCommand() {
        let command = commandText
        commandText = ""

        container.terminalEngine.execute(command)
    }
}
