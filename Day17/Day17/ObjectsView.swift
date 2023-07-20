import SwiftUI
import RealityKit

struct ObjectsView: View {

    var viewModel: ViewModel

    var body: some View {
        @Bindable var viewModel = viewModel

        RealityView { content in
            let entity = ModelEntity(
                mesh: .generateBox(size: 0.1, cornerRadius: 0),
                materials: [],
                collisionShape: .generateBox(size: SIMD3<Float>(repeating: 0.1)),
                mass: 0.0
            )
            entity.position = .zero

            viewModel.cubeEntity = entity
            viewModel.updateTransparency()
            viewModel.updateScale()
            content.add(entity)
            
        } update: { content in
            viewModel.updateScale()
            viewModel.updateTransparency()
        }
    }
}

#Preview {
    ObjectsView(viewModel: ViewModel())
}
