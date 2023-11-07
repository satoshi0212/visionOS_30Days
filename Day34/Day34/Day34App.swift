import SwiftUI

@main
@MainActor
struct Day34App: App {

    @State private var model = ImageTrackingModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
                .environment(model)
        }
    }
}
