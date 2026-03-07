import SwiftUI

struct RootView: View {
    @StateObject private var container = AppContainer()

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 0) {
                DevToolbarView()

                TerminalView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                LogPanelView()

                KeyboardInputBar()
            }
        }
        .environmentObject(container)
    }
}