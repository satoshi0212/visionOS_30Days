import SwiftUI
import RealityKit
import Observation

@Observable
class ViewModel {

    private var contentEntity = Entity()
    var messages: [String] = []

    func addMessage(_ message: String) async {
        messages.append(message)
        try? await removeOldMessages()
    }

    private func removeOldMessages() async throws {
        try await Task.sleep(for: .seconds(4.0))
        if !messages.isEmpty {
            messages.removeFirst()
        }
    }

    func setupContentEntity() -> Entity {
        return contentEntity
    }

    func getTargetEntity(name: String) -> Entity? {
        return contentEntity.children.first { $0.name == name}
    }

    func addNull(name: String, value: EntityTargetValue<SpatialTapGesture.Value>?) -> ModelEntity {
        let entity = ModelEntity(
            mesh: .generatePlane(width: 0, depth: 0),
            materials: [SimpleMaterial(color: .white, isMetallic: false)],
            collisionShape: .generateBox(size: SIMD3<Float>(repeating: 0)),
            mass: 0.0
        )

        entity.name = name

        let pos = (value != nil) ? value!.convert(value!.location3D, from: .local, to: .scene) : SIMD3<Float>.zero
        entity.position = pos
        entity.components.set(InputTargetComponent(allowedInputTypes: .indirect))
        entity.generateCollisionShapes(recursive: true)

        contentEntity.addChild(entity)

        return entity
    }

    func addCube(name: String, posision: SIMD3<Float>, color: UIColor) -> ModelEntity {
        let entity = ModelEntity(
            mesh: .generateBox(size: 0.3),
            materials: [SimpleMaterial(color: color, isMetallic: false)],
            collisionShape: .generateBox(size: SIMD3<Float>(repeating: 0.3)),
            mass: 0.0
        )

        entity.name = name
        entity.position = posision
        entity.components.set(InputTargetComponent(allowedInputTypes: .all))
        entity.generateCollisionShapes(recursive: true)

        contentEntity.addChild(entity)

        return entity
    }
}
