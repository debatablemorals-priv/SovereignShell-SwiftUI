import SwiftUI

struct DevToolbarView: View {

    @EnvironmentObject private var container: AppContainer

    var body: some View {
        HStack {

            status("AIS",
                   container.securityState.isAISValid,
                   "VALID",
                   "INVALID")

            status("LOCK",
                   container.securityState.isLocked,
                   "LOCKED",
                   "OPEN")

            Spacer()
        }
        .padding(8)
        .background(ThemeAuthority.background)
        .font(ThemeAuthority.font)
    }

    private func status(
        _ label: String,
        _ state: Bool,
        _ trueText: String,
        _ falseText: String
    ) -> some View {

        HStack {
            Text(label)

            Text(state ? trueText : falseText)
                .foregroundColor(state ? ThemeAuthority.warning : ThemeAuthority.terminalText)
        }
    }
}
