import SwiftUI

@main
struct Day40App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .defaultSize(CGSize(width: 600, height: 300))

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }

    init() {
        DeviceComponent.registerComponent()
        DeviceSystem.registerSystem()
        ChaserComponent.registerComponent()
        ChaserSystem.registerSystem()
    }
}
