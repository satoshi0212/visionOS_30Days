import SwiftUI
import RealityKit
import Observation

@Observable
class ViewModel {

    private var contentEntity = Entity()
//    private let placeOffset: SIMD3<Float> = .init(x: 0.0, y: 1.8, z: -0.5)
    private let placeOffset: SIMD3<Float> = .init(x: 0.0, y: 0.0, z: 0.0)

    func setupContentEntity() -> Entity {
        contentEntity.components.set(InputTargetComponent(allowedInputTypes: .indirect))
        contentEntity.components.set(CollisionComponent(shapes: [ShapeResource.generateSphere(radius: 20)], isStatic: true))
        return contentEntity
    }

    func addAxis(matrix: simd_float4x4) {
        let entity = try! Entity.load(named: "axis.usdz")
        entity.scale *= 5
        entity.position = matrix.position + placeOffset
        entity.orientation = matrix.rotation
        contentEntity.addChild(entity)
    }
}
