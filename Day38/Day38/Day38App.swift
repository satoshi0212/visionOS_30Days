import SwiftUI

@main
@MainActor
struct Day38App: App {

    @State private var appState = AppState()

    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.scenePhase) private var scenePhase

    var body: some SwiftUI.Scene {
        WindowGroup {
            ContentView(
                appState: appState,
                immersiveSpaceIdentifier: "ImmersiveSpace"
            )
        }
        .defaultSize(width: 360, height: 360)
        .windowResizability(.contentSize)

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView(
                appState: appState
            )
        }
        .onChange(of: scenePhase, initial: true) {
            if scenePhase != .active {
                if appState.immersiveSpaceOpened {
                    Task {
                        await dismissImmersiveSpace()
                        appState.didLeaveImmersiveSpace()
                    }
                }
            }
        }
    }
}
