import SwiftUI

struct ContentView: View {

    var viewModel: ViewModel

    var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack {
            ObjectsView(viewModel: viewModel)
        }
        .ornament(
            visibility: .visible,
            attachmentAnchor: .scene(.bottom)
        ) {
            BottomControls(viewModel: viewModel)
        }
    }
}

#Preview {
    ContentView(viewModel: ViewModel())
}
