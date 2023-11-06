import SwiftUI

@main
@MainActor
struct Day33App: App {
    
    @State private var model = PlaneDetectionModel()

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
