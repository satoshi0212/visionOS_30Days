import SwiftUI
import RealityKit

struct ImmersiveView: View {

    var viewModel: ViewModel

    var body: some View {
        RealityView { content in
            content.add(viewModel.setupContentEntity())
            _ = viewModel.addText(text: "Hello! 日本語！")
        }
    }
}

#Preview {
    ImmersiveView(viewModel: ViewModel())
        .previewLayout(.sizeThatFits)
}
