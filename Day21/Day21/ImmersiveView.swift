import SwiftUI
import RealityKit

struct ImmersiveView: View {

    var viewModel: ViewModel

    var body: some View {
        RealityView { content in
            content.add(viewModel.setupContentEntity())
        }
        .task {
            try? await viewModel.setSnapshot()
        }
    }
}

#Preview {
    ImmersiveView(viewModel: ViewModel())
        .previewLayout(.sizeThatFits)
}
