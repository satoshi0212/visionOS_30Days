import SwiftUI
import RealityKit

struct ContentView: View {

    @Environment(ViewModel.self) private var viewModel

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {

        @Bindable var viewModel = viewModel

        VStack {
            Toggle(viewModel.showImmersiveSpace ? "LongPress to back" : "Show ImmersiveSpace", isOn: $viewModel.showImmersiveSpace)
                .toggleStyle(.button)
        }
        .padding()
        .onChange(of: viewModel.showImmersiveSpace) { _, newValue in
            Task {
                if newValue {
                    await openImmersiveSpace(id: "ImmersiveSpace")
                } else {
                    await dismissImmersiveSpace()
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(ViewModel())
}
