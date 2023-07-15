import SwiftUI

@main
struct Day14App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace_Progressive") {
            ImmersiveView(imageName: "park_scene")
        }.immersionStyle(selection: .constant(.progressive), in: .progressive)

        ImmersiveSpace(id: "ImmersiveSpace_Full") {
            ImmersiveView(imageName: "beach_scene")
        }.immersionStyle(selection: .constant(.full), in: .full)
    }
}
