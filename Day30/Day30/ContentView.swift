import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {

    @Environment(PlayerModel.self) private var playerModel

    @State private var showImmersiveSpace = false
    @State private var immersiveSpaceIsShown = false

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {
        VStack {
            Toggle("Debug: Show ImmersiveSpace", isOn: $showImmersiveSpace)
                .toggleStyle(.button)

            PlayerView()
                .onAppear() {
                    let video = Video(id: 1, url: URL(string: hlsUrlString)!, title: "Video")
                    playerModel.loadVideo(video)
                }
                .onChange(of: playerModel.videoAction) { oldValue, newValue in
                    //print(newValue)

                    switch newValue {
                    case .darkRoom:
                        showImmersiveSpace = true
                    case .lightRoom:
                        showImmersiveSpace = false
                    case .none:
                        print("")
                    case .reset:
                        showImmersiveSpace = false
                    case .fireworks:
                        print("")
                    }
                }
        }
        .onChange(of: showImmersiveSpace) { _, newValue in
            Task {
                if newValue {
                    switch await openImmersiveSpace(id: "ImmersiveSpace") {
                    case .opened:
                        immersiveSpaceIsShown = true
                    case .error, .userCancelled:
                        fallthrough
                    @unknown default:
                        immersiveSpaceIsShown = false
                        showImmersiveSpace = false
                    }
                } else if immersiveSpaceIsShown {
                    await dismissImmersiveSpace()
                    immersiveSpaceIsShown = false
                }
            }
        }

    }
}

#Preview {
    ContentView()
        .environment(PlayerModel())
}
