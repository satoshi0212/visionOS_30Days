import SwiftUI

@main
struct Day37App: App {

    @State var peerToPeerModel = PeerToPeerModel()

    var body: some Scene {
        WindowGroup() {
            ContentView()
                .environment(peerToPeerModel)
        }
    }
}
