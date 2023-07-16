import SwiftUI

struct ContentView: View {

    @Environment(ViewModel.self) private var model

    var body: some View {

        @Bindable var model = model

        NavigationStack {
            VStack {
                WindowToggle(
                    title: model.selectedType.title,
                    id: "model",
                    isShowing: $model.isShowing)
            }
        }
    }

    private struct WindowToggle: View {
        var title: String
        var id: String
        @Binding var isShowing: Bool

        @Environment(\.openWindow) private var openWindow
        @Environment(\.dismissWindow) private var dismissWindow

        var body: some View {
            Toggle(title, isOn: $isShowing)
                .onChange(of: isShowing) { wasShowing, isShowing in
                    if isShowing {
                        openWindow(id: id)
                    } else {
                        dismissWindow(id: id)
                    }
                }
                .toggleStyle(.button)
        }
    }
}

#Preview {
    ContentView()
        .environment(ViewModel())
}
