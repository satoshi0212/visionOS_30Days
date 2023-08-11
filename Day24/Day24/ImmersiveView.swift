import SwiftUI
import RealityKit

struct ImmersiveView: View {

    var viewModel: ViewModel

    var body: some View {
        RealityView { content in
            content.add(viewModel.setupContentEntity())
        }
        .onAppear() {
            viewModel.play()
        }
        .onDisappear() {
            viewModel.pause()
        }
    }
}

#Preview {
    ImmersiveView(viewModel: ViewModel())
        .previewLayout(.sizeThatFits)
}
