import SwiftUI
import RealityKit

@MainActor
struct ImmersiveView: View {
    
    let appState: AppState

    @State private var viewModel = ViewModel()

    var body: some View {
        RealityView { content in
            content.add(viewModel.setupContentEntity())
            viewModel.appState = appState

            Task {
                await viewModel.runARKitSession()
            }
        }
        .task {
            await viewModel.processWorldAnchorUpdates()
        }
        .onAppear() {
            print("Entering immersive space.")
            appState.immersiveSpaceOpened(with: viewModel)
        }
        .onDisappear() {
            print("Leaving immersive space.")
            appState.didLeaveImmersiveSpace()
        }
    }
}
