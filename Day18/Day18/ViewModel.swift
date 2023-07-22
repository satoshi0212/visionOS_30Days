import RealityKit
import Observation

@Observable
class ViewModel {

    private var contentEntity = Entity()

    func setupContentEntity() -> Entity {
        return contentEntity
    }

    func addText(text: String) -> Entity {

        let textMeshResource: MeshResource = .generateText(text,
                                                           extrusionDepth: 0.05,
                                                           font: .systemFont(ofSize: 0.3),
                                                           containerFrame: .zero,
                                                           alignment: .center,
                                                           lineBreakMode: .byWordWrapping)

        let material = UnlitMaterial(color: .white)

        let textEntity = ModelEntity(mesh: textMeshResource, materials: [material])
        textEntity.position = SIMD3(x: -(textMeshResource.bounds.extents.x / 2), y: 1.5, z: -2)

        contentEntity.addChild(textEntity)

        return textEntity
    }
}
