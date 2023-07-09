import SwiftUI

@main
struct Day11App: App {
    
    @State private var model = ViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(model)
        }
    }
}
