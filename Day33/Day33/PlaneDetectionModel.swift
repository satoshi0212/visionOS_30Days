import ARKit
import SwiftUI
import RealityKit
import Observation

@Observable
@MainActor
class PlaneDetectionModel {

    private let session = ARKitSession()
    private let planeDetectionProvider = PlaneDetectionProvider(alignments: [.horizontal, .vertical])

    private var contentEntity = Entity()
    private var entityMap: [UUID: Entity] = [:]

    // MARK: - Public

    func setupContentEntity() -> Entity {
        return contentEntity
    }

    func runSession() async {
        do {
            if PlaneDetectionProvider.isSupported {
                try await session.run([planeDetectionProvider])
                print("[\(type(of: self))] [\(#function)] session.run")
            }
        } catch {
            print(error)
        }
    }

    func processPlaneDetectionUpdates() async {
        print("[\(type(of: self))] [\(#function)] called")

        for await update in planeDetectionProvider.anchorUpdates {
            print("[\(type(of: self))] [\(#function)] anchorUpdates")

            let planeAnchor = update.anchor

            // Skip planes that are windows.
            if planeAnchor.classification == .window { continue }

            switch update.event {
            case .added, .updated:
                updatePlane(planeAnchor)
                print("[\(type(of: self))] added/updated: \(planeAnchor.description)")
            case .removed:
                removePlane(planeAnchor)
                print("[\(type(of: self))] removed: \(planeAnchor.description)")
            }
        }
    }

    func monitorSessionEvents() async {
        for await event in session.events {
            switch event {
            case .authorizationChanged(type: _, status: let status):
                print("Authorization changed to: \(status)")
                if status == .denied {
                    print("Authorization status: denied")
                }
            case .dataProviderStateChanged(dataProviders: let providers, newState: let state, error: let error):
                print("Data provider changed: \(providers), \(state)")
                if let error {
                    print("Data provider reached an error state: \(error)")
                }
            @unknown default:
                fatalError("Unhandled new event type \(event)")
            }
        }
    }

    // MARK: - Private

    private func updatePlane(_ anchor: PlaneAnchor) {
        if entityMap[anchor.id] == nil {
            // Add a new entity to represent this plane.
            let material = UnlitMaterial(color: anchor.classification.color)
            let entity = ModelEntity(mesh: .generatePlane(width: anchor.geometry.extent.width, depth: anchor.geometry.extent.height), materials: [material])
            entityMap[anchor.id] = entity
            contentEntity.addChild(entity)
        }
        entityMap[anchor.id]?.transform = Transform(matrix: anchor.originFromAnchorTransform)
    }

    private func removePlane(_ anchor: PlaneAnchor) {
        entityMap[anchor.id]?.removeFromParent()
        entityMap.removeValue(forKey: anchor.id)
    }
}

private extension PlaneAnchor.Classification {

    var color: UIColor {
        switch self {
        case .wall:
            return UIColor.blue.withAlphaComponent(0.65)
        case .floor:
            return UIColor.red.withAlphaComponent(0.65)
        case .ceiling:
            return UIColor.green.withAlphaComponent(0.65)
        case .table:
            return UIColor.yellow.withAlphaComponent(0.65)
        case .door:
            return UIColor.brown.withAlphaComponent(0.65)
        case .seat:
            return UIColor.systemPink.withAlphaComponent(0.65)
        case .window:
            return UIColor.orange.withAlphaComponent(0.65)
        case .undetermined:
            return UIColor.lightGray.withAlphaComponent(0.65)
        case .notAvailable:
            return UIColor.gray.withAlphaComponent(0.65)
        case .unknown:
            return UIColor.black.withAlphaComponent(0.65)
        @unknown default:
            return UIColor.purple
        }
    }
}
