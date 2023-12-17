import SwiftUI

@main
struct Day16App: App {

    @State private var model = ViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(model)
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
                .environment(model)
        }
    }
}
