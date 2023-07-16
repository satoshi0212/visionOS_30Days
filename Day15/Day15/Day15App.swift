import SwiftUI

@main
struct Day15App: App {

    @State private var model = ViewModel()

    var body: some Scene {
        WindowGroup("home") {
            HomeView()
                .environment(model)
        }
        .windowStyle(.plain)

        WindowGroup(id: "model") {
            VolumetricView()
                .environment(model)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 0.6, height: 0.6, depth: 0.6, in: .meters)
    }
}
