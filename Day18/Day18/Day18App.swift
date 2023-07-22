import SwiftUI

@main
struct Day18App: App {

    @State private var viewModel = ViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView(viewModel: viewModel)
        }
    }
}
