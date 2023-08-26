import SwiftUI
import RealityKit
import Combine
import RealityKitContent

struct ImmersiveView: View {

    @Environment(PlayerModel.self) private var playerModel

    @State private var fireworksScene: Entity!

    var body: some View {
        RealityView { content in
            let rootEntity = Entity()
            rootEntity.addSkybox(imageName: "Starfield")
            content.add(rootEntity)

            if let scene = try? await Entity(named: "Fireworks", in: realityKitContentBundle) {
                content.add(scene)
                scene.isEnabled = false
                fireworksScene = scene
            }
        }
        .onChange(of: playerModel.videoAction) { oldValue, newValue in
            switch newValue {
            case .darkRoom:
                print("")
            case .lightRoom:
                print("")
            case .none:
                print("")
            case .reset:
                fireworksScene.isEnabled = false
            case .fireworks:
                fireworksScene.isEnabled = true
            }
        }
    }
}

#Preview {
    ImmersiveView()
        .previewLayout(.sizeThatFits)
}

extension Entity {

    func addSkybox(imageName: String) {
        let subscription = TextureResource.loadAsync(named: imageName).sink(
            receiveCompletion: {
                switch $0 {
                case .finished: break
                case .failure(let error): assertionFailure("\(error)")
                }
            },
            receiveValue: { [weak self] texture in
                guard let self = self else { return }

                var material = UnlitMaterial()
                material.color = .init(texture: .init(texture))
                self.components.set(ModelComponent(
                    mesh: .generateSphere(radius: 1E3),
                    materials: [material]
                ))
                self.scale *= .init(x: -1, y: 1, z: 1)
                self.transform.translation += SIMD3<Float>(0.0, 1.0, 0.0)
            }
        )
        components.set(Entity.SubscriptionComponent(subscription: subscription))
    }

    struct SubscriptionComponent: Component {
        var subscription: AnyCancellable
    }
}
