import Observation
import RealityKit
import SwiftUI

@Observable
class ViewModel {

    private var contentEntity = Entity()
    var targetSnapshot: UIImage? = nil

    func setupContentEntity() -> Entity {
        contentEntity.components.set(InputTargetComponent(allowedInputTypes: .indirect))

        // note: 1E3 did not work when using simulator
        contentEntity.components.set(CollisionComponent(shapes: [ShapeResource.generateSphere(radius: 1E2)], isStatic: true))

        return contentEntity
    }

    func addModelEntity(value: EntityTargetValue<SpatialTapGesture.Value>) {
        let modelEntity = ModelEntity(mesh: MeshResource.generatePlane(width: Float(targetSize.width) * 0.001, height: Float(targetSize.height) * 0.001))
        modelEntity.generateCollisionShapes(recursive: true)
        modelEntity.model?.materials = [createTexture()]
        modelEntity.position = value.convert(value.location3D, from: .local, to: .scene)
        contentEntity.addChild(modelEntity)
    }

    func createTexture() -> UnlitMaterial {
        guard let snapshot = targetSnapshot else { return UnlitMaterial(color: .black) }

        // note: color will be different if .raw is specified
        let texture = try! TextureResource.generate(from: snapshot.cgImage!, options: .init(semantic: .color))

        var material = UnlitMaterial()

        // note: color will be different if anything other than .white is specified
        material.color = .init(tint: .white, texture: .init(texture))

        // note: Using 1.0 was too dark, so 2.0 is used
        material.blending = .transparent(opacity: PhysicallyBasedMaterial.Opacity(floatLiteral: 2.0))

        return material
    }
}
