import SwiftUI
import RealityKit
import ARKit

@MainActor class Day4ViewModel: ObservableObject {

    private let session = ARKitSession()
    private let worldTracking = WorldTrackingProvider()
    private var contentEntity = Entity()

    func setupContentEntity() -> Entity {
        let box = ModelEntity(mesh: .generateBox(width: 0.5, height: 0.5, depth: 0.5))
        contentEntity.addChild(box)
        return contentEntity
    }

    func runSession() async {

        print("WorldTrackingProvider.isSupported: \(WorldTrackingProvider.isSupported)")
        print("PlaneDetectionProvider.isSupported: \(PlaneDetectionProvider.isSupported)")
        print("SceneReconstructionProvider.isSupported: \(SceneReconstructionProvider.isSupported)")
        print("HandTrackingProvider.isSupported: \(HandTrackingProvider.isSupported)")

        Task {
            let authorizationResult = await session.requestAuthorization(for: [.worldSensing])

            for (authorizationType, authorizationStatus) in authorizationResult {
                print("Authorization status for \(authorizationType): \(authorizationStatus)")
                switch authorizationStatus {
                case .allowed:
                    break
                case .denied:
                    // Need to handle this.
                    break
                case .notDetermined:
                    break
                @unknown default:
                    break
                }
            }
        }

        Task {
            try await session.run([worldTracking])

            for await update in worldTracking.anchorUpdates {
                switch update.event {
                case .added, .updated:
                    print("Anchor position updated.")
                case .removed:
                    print("Anchor position now unknown.")
                @unknown default:
                    break
                }
            }
        }
    }
}
