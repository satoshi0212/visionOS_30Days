import SwiftUI
import RealityKit
import Observation

@Observable
class ViewModel {

    private var contentEntity = Entity()

    func setupContentEntity() -> Entity {
        contentEntity.components.set(InputTargetComponent(allowedInputTypes: .indirect))
        contentEntity.components.set(CollisionComponent(shapes: [ShapeResource.generateSphere(radius: 20)], isStatic: true))
        return contentEntity
    }

    func addAxis(value: EntityTargetValue<SpatialTapGesture.Value>) {

        let entity = try! Entity.load(named: "axis.usdz")
        entity.scale *= 3
        entity.position = value.convert(value.location3D, from: .local, to: contentEntity.parent!)

        contentEntity.addChild(entity)
    }
}
