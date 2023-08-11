import SwiftUI

@main
struct Day25App: App {

    @State private var viewModel = ViewModel()

    var body: some Scene {
        WindowGroup("", id: "home") {
            ContentView(viewModel: viewModel)
        }
        .defaultSize(width: 480, height: 640)

        WindowGroup("", id: "other") {
            ContentViewOther(viewModel: viewModel)
        }
        .defaultSize(width: 480, height: 640)
    }
}
