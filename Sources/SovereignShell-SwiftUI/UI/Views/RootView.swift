import SwiftUI

struct RootView: View {
    var body: some View {
        VStack(spacing: 0) {
            DevToolbarView()

            Divider()

            TerminalView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()

            KeyboardInputBar()

            Divider()

            LogPanelView()
                .frame(maxWidth: .infinity)
                .frame(height: 220)
        }
    }
}
