import SwiftUI

@main
struct Day23App: App {

    @State private var viewModel = ViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView(viewModel: viewModel)
        }
    }
}
