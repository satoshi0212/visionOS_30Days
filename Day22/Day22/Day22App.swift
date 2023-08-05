import SwiftUI

@main
struct Day22App: App {

    @State private var viewModel = ViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView(viewModel: viewModel)
        }.immersionStyle(selection: .constant(.full), in: .full)
    }
}
