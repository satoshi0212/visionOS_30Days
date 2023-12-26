import SwiftUI

@main
struct Day36App: App {
    
    @State var viewModel = ViewModel(colorPixelFormat: .bgra8Unorm)

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(viewModel)
        }.windowStyle(.plain)
    }
}
