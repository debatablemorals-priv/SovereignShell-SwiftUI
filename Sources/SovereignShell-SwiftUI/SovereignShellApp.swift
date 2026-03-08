import SwiftUI

@main
struct SovereignShellApp: App {

    @StateObject
    private var container = AppContainer()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(container)
        }
    }
}
