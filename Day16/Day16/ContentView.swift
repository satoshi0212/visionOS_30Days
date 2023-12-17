import SwiftUI

struct ContentView: View {

    @Environment(ViewModel.self) private var model

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {

        @Bindable var model = model

        NavigationStack {
            Toggle(model.showImmersiveSpace ? "LongPress to Dismiss" : "Show ImmersiveSpace", isOn: $model.showImmersiveSpace)
                .toggleStyle(.button)
        }
        .onChange(of: model.showImmersiveSpace) { _, newValue in
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
