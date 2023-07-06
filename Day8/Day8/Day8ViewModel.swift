import SwiftUI
import RealityKit
import Observation

@Observable
class Day8ViewModel {

    private var contentEntity = Entity()

    func setupContentEntity() -> Entity {
        return contentEntity
    }

    func getTargetEntity(name: String) -> Entity? {
        return contentEntity.children.first { $0.name == name}
    }

    func addCube(name: String, posision: SIMD3<Float>, color: UIColor) -> ModelEntity {
        let entity = ModelEntity(
            mesh: .generateBox(size: 0.5, cornerRadius: 0),
            materials: [SimpleMaterial(color: color, isMetallic: false)],
            collisionShape: .generateBox(size: SIMD3<Float>(repeating: 0.5)),
            mass: 0.0
        )

        entity.name = name
        entity.position = posision
        entity.components.set(InputTargetComponent(allowedInputTypes: .indirect))
        entity.components.set(CollisionComponent(shapes: [ShapeResource.generateBox(size: SIMD3<Float>(repeating: 0.5))], isStatic: true))
        entity.components.set(HoverEffectComponent())

        contentEntity.addChild(entity)
        
        return entity
    }

    func playAnimation(entity: Entity) {
        let goUp = FromToByAnimation<Transform>(
            name: "goUp",
            from: .init(scale: .init(repeating: 1), translation: entity.position),
            to: .init(scale: .init(repeating: 1), translation: entity.position + .init(x: 0, y: 0.4, z: 0)),
            duration: 0.2,
            timing: .easeOut,
            bindTarget: .transform
        )

        let pause = FromToByAnimation<Transform>(
            name: "pause",
            from: .init(scale: .init(repeating: 1), translation: entity.position + .init(x: 0, y: 0.4, z: 0)),
            to: .init(scale: .init(repeating: 1), translation: entity.position + .init(x: 0, y: 0.4, z: 0)),
            duration: 0.1,
            bindTarget: .transform
        )

        let goDown = FromToByAnimation<Transform>(
            name: "goDown",
            from: .init(scale: .init(repeating: 1), translation: entity.position + .init(x: 0, y: 0.4, z: 0)),
            to: .init(scale: .init(repeating: 1), translation: entity.position),
            duration: 0.2,
            timing: .easeOut,
            bindTarget: .transform
        )

        let goUpAnimation = try! AnimationResource
            .generate(with: goUp)

        let pauseAnimation = try! AnimationResource
            .generate(with: pause)

        let goDownAnimation = try! AnimationResource
            .generate(with: goDown)

        let animation = try! AnimationResource.sequence(with: [goUpAnimation, pauseAnimation, goDownAnimation])

        entity.playAnimation(animation, transitionDuration: 0.5)
    }
}
