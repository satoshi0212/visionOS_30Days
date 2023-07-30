import Observation
import MapKit
import RealityKit

@Observable
class ViewModel {

    var selectedPlaceInfo: PlaceInfo?

    var placeInfoList: [PlaceInfo] = [
        PlaceInfo(name: "渋谷 / Shibuya", locationCoordinate: CLLocationCoordinate2DMake(35.6596165, 139.7001669)),
        PlaceInfo(name: "秋葉原 / Akihabara", locationCoordinate: CLLocationCoordinate2DMake(35.6987049, 139.7714407)),
        PlaceInfo(name: "歌舞伎町 / Kabuki-cho", locationCoordinate: CLLocationCoordinate2DMake(35.6937649, 139.7009477)),
    ]

    private var contentEntity = Entity()
    private var modelEntity: ModelEntity? = nil

    func setupContentEntity() -> Entity {
        let modelEntity = ModelEntity()

        let material = UnlitMaterial(color: .black)
        modelEntity.components.set(ModelComponent(
            mesh: .generateSphere(radius: 1E3),
            materials: [material]
        ))
        modelEntity.scale *= .init(x: -1, y: 1, z: 1)
        modelEntity.transform.translation += SIMD3<Float>(0.0, 1.0, 0.0)

        contentEntity.addChild(modelEntity)
        self.modelEntity = modelEntity

        return contentEntity
    }

    func setSnapshot() async throws {
        guard let placeInfo = selectedPlaceInfo else { return }

        Task { @MainActor in
            let sceneRequest = MKLookAroundSceneRequest(coordinate: placeInfo.locationCoordinate)
            guard let scene = try? await sceneRequest.scene else { return }

            let snapshotOptions = MKLookAroundSnapshotter.Options()
            snapshotOptions.size = CGSize(width: 512, height: 512)

            let snapshotter = MKLookAroundSnapshotter(scene: scene, options: snapshotOptions)
            guard let snapshotImage = try? await snapshotter.snapshot.image else { return }

            guard let cgImage = snapshotImage.cgImage else { return }
            guard let texture = try? TextureResource.generate(from: cgImage, options: TextureResource.CreateOptions.init(semantic: nil)) else { return }

            var material = self.modelEntity?.model?.materials[0] as! UnlitMaterial
            material.color = .init(texture: MaterialParameters.Texture(texture))
            self.modelEntity?.model?.materials[0] = material
        }
    }
}

struct PlaceInfo: Identifiable, Hashable {
    static func == (lhs: PlaceInfo, rhs: PlaceInfo) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    let id = UUID()
    let name: String
    let locationCoordinate: CLLocationCoordinate2D
}
