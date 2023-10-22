import SwiftUI
import RealityKit
import Combine

struct ImmersiveView: View {

    @State private var imageName: String
    @State var textureRequest: AnyCancellable?

    init(imageName: String) {
        self.imageName = imageName
    }

    var body: some View {
        RealityView { content in

            let rootEntity = Entity()

             textureRequest = TextureResource.loadAsync(named: imageName).sink { (error) in
                 print(error)
             } receiveValue: { (texture) in
                 var material = UnlitMaterial()
                 material.color = .init(texture: .init(texture))
                 rootEntity.components.set(ModelComponent(
                     mesh: .generateSphere(radius: 1E3),
                     materials: [material]
                 ))
                 rootEntity.scale *= .init(x: -1, y: 1, z: 1)
                 rootEntity.transform.translation += SIMD3<Float>(0.0, 1.0, 0.0)
             }

            content.add(rootEntity)
        }
    }
}

#Preview {
    ImmersiveView(imageName: "park_scene")
        .previewLayout(.sizeThatFits)
}
