import SwiftUI

@main
struct Day3App: App {
    @State private var player = PlayerModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(player)
        }
    }
}
