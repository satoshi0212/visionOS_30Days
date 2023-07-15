import SwiftUI
import RealityKit

struct ContentView: View {

    @State var showImmersiveSpace_Progressive = false
    @State var showImmersiveSpace_Full = false

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {
        NavigationStack {
            VStack {
                Toggle("Show Progressive ImmersiveSpace", isOn: $showImmersiveSpace_Progressive)
                    .toggleStyle(.button)
                    .disabled(progressiveIsValid)

                Toggle("Show Full ImmersiveSpace", isOn: $showImmersiveSpace_Full)
                    .toggleStyle(.button)
                    .disabled(fullIsValid)
                    .padding(.top, 50)
            }
        }
        .onChange(of: showImmersiveSpace_Progressive) { _, newValue in
            Task {
                if newValue {
                    await openImmersiveSpace(id: "ImmersiveSpace_Progressive")
                } else {
                    await dismissImmersiveSpace()
                }
            }
        }
        .onChange(of: showImmersiveSpace_Full) { _, newValue in
            Task {
                if newValue {
                    await openImmersiveSpace(id: "ImmersiveSpace_Full")
                } else {
                    await dismissImmersiveSpace()
                }
            }
        }
    }

    var progressiveIsValid: Bool {
        return showImmersiveSpace_Full
    }

    var fullIsValid: Bool {
        return showImmersiveSpace_Progressive
    }
}

#Preview {
    ContentView()
}
