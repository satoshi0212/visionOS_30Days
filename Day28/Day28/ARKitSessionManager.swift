import SwiftUI
import ARKit
import RealityKit

@MainActor
class ARKitSessionManager: ObservableObject {

    let session = ARKitSession()
    let worldTrackingProvider = WorldTrackingProvider()

    func startSession() async {
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
            if WorldTrackingProvider.isSupported {
                do {
                    try await session.run([worldTrackingProvider])
                } catch {
                    assertionFailure("Failed to run session: \(error)")
                }
            }
        }
    }

    func stopSession() {
        session.stop()
    }

    func handleWorldTrackingUpdates() async {
        print("\(#function): called")
        for await update in worldTrackingProvider.anchorUpdates {
            print("\(#function): anchorUpdates: \(update)")
        }
    }

    func monitorSessionEvent() async {
        print("\(#function): called")
        for await event in session.events {
            print("\(#function): \(event)")
        }
    }

    func reportDevicePose() {
        if let pose = worldTrackingProvider.queryDeviceAnchor(atTimestamp: CACurrentMediaTime()) {
            print("pose: \(pose)")
        } else {
            print("pose: nil")
        }
    }

    func getOriginFromDeviceTransform() -> simd_float4x4 {
        guard let pose = worldTrackingProvider.queryDeviceAnchor(atTimestamp: CACurrentMediaTime()) else {
            return simd_float4x4()
        }
        return pose.originFromAnchorTransform
    }

//    func lookAtCamera(entity: Entity) {
//        guard let pose = worldTrackingProvider.queryPose(atTimestamp: CACurrentMediaTime()) else { return }
//        let cameraTransform = Transform(matrix: pose.originFromDeviceTransform)
//        let translation = entity.transform.translation
//        entity.look(at: cameraTransform.translation,
//                    from: entity.position(relativeTo: nil),
//                    relativeTo: nil,
//                    forward: .positiveZ)
//        entity.transform.translation = translation
//    }
}
