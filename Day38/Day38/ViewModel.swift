import SwiftUI
import RealityKit
import ARKit

@Observable
class ViewModel {

    var appState: AppState? = nil

    private let worldTracking = WorldTrackingProvider()

    private var rootEntity = Entity()
    private var anchoredObjects: [UUID: Entity] = [:]
    private var objectsBeingAnchored: [UUID: Entity] = [:]
    private var worldAnchors: [UUID: WorldAnchor] = [:]

    private let boxSize: Float = 0.4

    func getTargetEntity(name: String) -> Entity? {
        return rootEntity.children.first { $0.name == name}
    }

    func setupContentEntity() -> Entity {
        clear()
        return rootEntity
    }

    func clear() {
        if let entity = getTargetEntity(name: "notAnchored") {
            entity.removeFromParent()
        }

        if let entity = getTargetEntity(name: "anchored") {
            entity.removeFromParent()
        }

        anchoredObjects.removeAll()
        objectsBeingAnchored.removeAll()
        worldAnchors.removeAll()
    }

    @MainActor
    func setupCubes() async {
        clear()

        let entity = makeCube(name: "notAnchored", posision: SIMD3(x: -0.6, y: 1, z: -2), color: .blue)
        rootEntity.addChild(entity)

        let entity2 = makeCube(name: "anchored", posision: SIMD3(x: 0.6, y: 1, z: -2), color: .red)
        entity2.addChild(makeText(text: "anchored"))
        await attachObjectToWorldAnchor(entity2)
    }

    private func makeCube(name: String, posision: SIMD3<Float>, color: UIColor) -> Entity {
        let entity = ModelEntity(
            mesh: .generateBox(size: boxSize, cornerRadius: 0),
            materials: [SimpleMaterial(color: color, isMetallic: false)]
        )

        entity.name = name
        entity.position = posision
        entity.components.set(InputTargetComponent())
        entity.components.set(HoverEffectComponent())
        entity.generateCollisionShapes(recursive: true)

        return entity
    }

    private func makeText(text: String) -> ModelEntity {
        let fontSize: CGFloat = 0.06

        let mesh = MeshResource.generateText(
            text,
            extrusionDepth: 0.001,
            font: .systemFont(ofSize: fontSize),
            containerFrame: CGRect(origin: .zero, size: CGSize(width: CGFloat(boxSize), height: CGFloat(boxSize))),
            alignment: .center
        )

        let entity = ModelEntity(
            mesh: mesh,
            materials: [SimpleMaterial(color: .white, isMetallic: false)]
        )

        entity.position.x = -(boxSize / 2)
        entity.position.y = -boxSize + Float(fontSize / 2)
        entity.position.z = boxSize / 2 + 0.01

        return entity
    }

    // MARK: - ARKit and Anchor handlings

    @MainActor
    func runARKitSession() async {
        do {
            try await appState!.arkitSession.run([worldTracking])
        } catch {
            return
        }
    }

    @MainActor
    func processWorldAnchorUpdates() async {
        for await anchorUpdate in worldTracking.anchorUpdates {
            process(anchorUpdate)
        }
    }

    @MainActor
    func process(_ anchorUpdate: AnchorUpdate<WorldAnchor>) {
        let anchor = anchorUpdate.anchor

        if anchorUpdate.event != .removed {
            worldAnchors[anchor.id] = anchor
        } else {
            worldAnchors.removeValue(forKey: anchor.id)
        }

        switch anchorUpdate.event {
        case .added:
            if let objectBeingAnchored = objectsBeingAnchored[anchor.id] {
                objectsBeingAnchored.removeValue(forKey: anchor.id)
                anchoredObjects[anchor.id] = objectBeingAnchored
                rootEntity.addChild(objectBeingAnchored)
            } else {
                if anchoredObjects[anchor.id] == nil {
                    Task {
                        //print("No object is attached to anchor \(anchor.id) - it can be deleted.")
                        await removeAnchorWithID(anchor.id)
                    }
                }
            }
            fallthrough
        case .updated:
            let object = anchoredObjects[anchor.id]
            object?.position = anchor.originFromAnchorTransform.translation
            object?.orientation = anchor.originFromAnchorTransform.rotation
            object?.isEnabled = anchor.isTracked
        case .removed:
            let object = anchoredObjects[anchor.id]
            object?.removeFromParent()
            anchoredObjects.removeValue(forKey: anchor.id)
        }
    }

    @MainActor
    func attachObjectToWorldAnchor(_ object: Entity) async {
        let anchor = WorldAnchor(originFromAnchorTransform: object.transformMatrix(relativeTo: nil))
        objectsBeingAnchored[anchor.id] = object
        do {
            try await worldTracking.addAnchor(anchor)
        } catch {
            if let worldTrackingError = error as? WorldTrackingProvider.Error, worldTrackingError.code == .worldAnchorLimitReached {
                print(
"""
Unable to place object "\(object.name)". You’ve placed the maximum number of objects.
Remove old objects before placing new ones.
"""
                )
            } else {
                print("Failed to add world anchor \(anchor.id) with error: \(error).")
            }

            objectsBeingAnchored.removeValue(forKey: anchor.id)
            object.removeFromParent()
            return
        }
    }

    func removeAnchorWithID(_ uuid: UUID) async {
        do {
            try await worldTracking.removeAnchor(forID: uuid)
        } catch {
            //print("Failed to delete world anchor \(uuid) with error \(error).")
        }
    }
}
