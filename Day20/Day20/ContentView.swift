import SwiftUI

struct ContentView: View {

    var viewModel: ViewModel
    private let channelId = ""

    var body: some View {

        @Bindable var viewModel = viewModel

        NavigationStack {
            VStack {
                Text(viewModel.messages.map { $0.text }.joined(separator: "\n"))
                    .padding()
                .task {
                    try? await viewModel.fetchData(channelId: channelId, limit: 5)
                }
                .onDisappear {
                    viewModel.stopFetchingData()
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView(viewModel: ViewModel())
}
