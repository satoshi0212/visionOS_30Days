import SwiftUI
import RealityKit

struct ImmersiveView: View {

    @State var viewModel = ViewModel()

    var body: some View {
        RealityView { content in
            content.add(viewModel.setupContentEntity())

            viewModel.addCube(name: "cube1", posision: SIMD3(x: -0.6, y: 1, z: -2), color: .red)
            viewModel.addCube(name: "cube2", posision: SIMD3(x: 0.6, y: 1, z: -2), color: .green)
        }
        .task {
            viewModel.configure()
        }
        .onDisappear {
            viewModel.close()
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    let isHighJump = (value.entity.name == "cube2")
                    viewModel.playAnimation(entity: value.entity, isHighJump: isHighJump)
                }
        )
    }
}

#Preview {
    ImmersiveView()
        .previewLayout(.sizeThatFits)
}
