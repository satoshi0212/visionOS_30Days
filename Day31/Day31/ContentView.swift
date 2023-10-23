import SwiftUI

struct ContentView: View {

    @Environment(PlayerViewModel.self) private var viewModel

    var body: some View {
        VStack {
            SystemPlayerView()
                .onAppear {
                    viewModel.play()
                }

            HStack {
                Button("Trim") {
                    Task {
                        await viewModel.startTrimming()
                    }
                }
                Button("Play") {
                    viewModel.play()
                }
                Button("Pause") {
                    viewModel.pause()
                }
            }
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
