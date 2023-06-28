import SwiftUI
import RealityKit

struct ContentView: View {

    @Environment(PlayerModel.self) private var player

    var body: some View {
        VStack {
            PlayerView()
                .onAppear() {
                    let video = Video(id: 1, url: URL(string: "http://playgrounds-cdn.apple.com/assets/beach/index.m3u8")!, title: "Day3 Video")
                    player.loadVideo(video)
                }
            Button("Play") {
                player.play()
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(PlayerModel())
}
