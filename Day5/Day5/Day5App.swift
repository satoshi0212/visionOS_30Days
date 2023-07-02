import SwiftUI

@main
struct Day5App: App {
    var body: some Scene {
        WindowGroup() {
            ContentView()
        }
        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
