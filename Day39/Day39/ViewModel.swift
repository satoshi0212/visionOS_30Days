import ARKit
import RealityKit

@Observable
class ViewModel {

    var appState: AppState? = nil

    let sceneReconstruction = SceneReconstructionProvider()
    let contentEntity = Entity()

    private var meshEntities = [UUID: ModelEntity]()

    func setupContentEntity() -> Entity {
        return contentEntity
    }

    var dataProvidersAreSupported: Bool {
        SceneReconstructionProvider.isSupported
    }

    var isReadyToRun: Bool {
        sceneReconstruction.state == .initialized
    }

    // MARK: - ARKit and Anchor handlings

    @MainActor
    func runARKitSession() async {
        do {
            try await appState!.arkitSession.run([sceneReconstruction])
        } catch {
            return
        }
    }

    @MainActor
    func processReconstructionUpdates() async {
        for await update in sceneReconstruction.anchorUpdates {
            let meshAnchor = update.anchor

            switch update.event {
            case .added:
                let entity = try! await generateModelEntity(geometry: meshAnchor.geometry)
                entity.transform = Transform(matrix: meshAnchor.originFromAnchorTransform)
                meshEntities[meshAnchor.id] = entity
                contentEntity.addChild(entity)
            case .updated:
                guard let entity = meshEntities[meshAnchor.id] else { continue }
                entity.transform = Transform(matrix: meshAnchor.originFromAnchorTransform)
            case .removed:
                meshEntities[meshAnchor.id]?.removeFromParent()
                meshEntities.removeValue(forKey: meshAnchor.id)
            }
        }
    }

    @MainActor
    func generateModelEntity(geometry: MeshAnchor.Geometry) async throws -> ModelEntity {
        var desc = MeshDescriptor()
        let posValues = geometry.vertices.asSIMD3(ofType: Float.self)
        desc.positions = .init(posValues)
        let normalValues = geometry.normals.asSIMD3(ofType: Float.self)
        desc.normals = .init(normalValues)
        do {
            desc.primitives = .polygons(
                (0..<geometry.faces.count).map { _ in UInt8(3) },
                (0..<geometry.faces.count * 3).map {
                    geometry.faces.buffer.contents()
                        .advanced(by: $0 * geometry.faces.bytesPerIndex)
                        .assumingMemoryBound(to: UInt32.self).pointee
                }
            )
        }
        let meshResource = try MeshResource.generate(from: [desc])
        var material = SimpleMaterial(color: .green.withAlphaComponent(0.8), isMetallic: false)
        material.triangleFillMode = .lines
        let modelEntity = ModelEntity(mesh: meshResource, materials: [material])
        return modelEntity
    }
}

extension GeometrySource {

    @MainActor
    func asArray<T>(ofType: T.Type) -> [T] {
        assert(MemoryLayout<T>.stride == stride, "Invalid stride \(MemoryLayout<T>.stride); expected \(stride)")
        return (0..<self.count).map {
            buffer.contents().advanced(by: offset + stride * Int($0)).assumingMemoryBound(to: T.self).pointee
        }
    }

    @MainActor
    func asSIMD3<T>(ofType: T.Type) -> [SIMD3<T>] {
        return asArray(ofType: (T, T, T).self).map { .init($0.0, $0.1, $0.2) }
    }
}
