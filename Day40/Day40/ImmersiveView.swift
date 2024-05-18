import SwiftUI
import RealityKit

struct ImmersiveView: View {

    var body: some View {
        RealityView { content in
            let deviceEntity = Entity()
            deviceEntity.components.set(DeviceComponent())
            content.add(deviceEntity)

            let bird = await BirdEntity(name: "001")
            bird.scale *= 2
            bird.position.y = 2.0
            bird.position.z = -2.0

            bird.components.set(
                ChaserComponent(
                    chaseSpeed: Constants.Chaser.chaseSpeed,
                    circleSpeed: Constants.Chaser.circleSpeed,
                    orbit: bird.orbit,
                    placeHolder: bird.placeHolder)
            )

            content.add(bird)
        }
    }
}
