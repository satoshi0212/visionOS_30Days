import SwiftUI
import RealityKit
import UniformTypeIdentifiers

struct ContentViewOther: View {

    var viewModel: ViewModel

    var body: some View {

        @Bindable var viewModel = viewModel

        VStack {
            TargetView(items: viewModel.rightListItems)
                .dropDestination(for: String.self) { items, location in
                    for item in items {
                        viewModel.leftListItems.removeAll { $0 == item }
                        if !viewModel.rightListItems.contains(item) {
                            viewModel.rightListItems.append(item)
                        }
                    }
                    return true
                }
        }
        .padding()
    }
}

#Preview(windowStyle: .automatic) {
    ContentView(viewModel: ViewModel())
}
