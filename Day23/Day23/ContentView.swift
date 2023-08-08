import SwiftUI
import RealityKit

struct ContentView: View {

    var viewModel: ViewModel

    @State private var showImmersiveSpace = false

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {

        @Bindable var viewModel = viewModel

        NavigationStack {
            VStack {
                Text(viewModel.messages.map { $0.text }.joined(separator: "\n"))
                    .padding()
                .task {
                    try? await viewModel.fetchDataOnce(channelId: viewModel.targetChannelId, limit: 5)
                }
            }
            VStack {
                Toggle("Start In-room SlackViewer", isOn: $showImmersiveSpace)
                    .toggleStyle(.button)
            }
        }
        .onChange(of: showImmersiveSpace) { _, newValue in
            Task {
                if newValue {
                    try? await viewModel.startFetchingData(channelId: viewModel.targetChannelId, limit: 5)
                    await openImmersiveSpace(id: "ImmersiveSpace")
                } else {
                    await dismissImmersiveSpace()
                    viewModel.stopFetchingData()
                }
            }
        }
    }
}

#Preview {
    ContentView(viewModel: ViewModel())
}
