import SwiftUI

@main
struct Day28App: App {

    @State private var viewModel = ViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(viewModel)
        }
        .defaultSize(width: windowTargetSize.width, height: windowTargetSize.height)

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
                .environment(viewModel)
        }
    }
}
