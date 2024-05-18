import ARKit
import RealityKit
import QuartzCore

struct DeviceComponent: Component {}

class DeviceSystem : System {
    static let query = EntityQuery(where: .has(DeviceComponent.self))

    private let arkitSession = ARKitSession()
    private let worldTrackingProvider = WorldTrackingProvider()

    required init(scene: RealityKit.Scene) {
        Task {
            try? await arkitSession.run([worldTrackingProvider])
        }
    }

    func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard let deviceAnchor = worldTrackingProvider.queryDeviceAnchor(atTimestamp: CACurrentMediaTime()) else { return }
            entity.transform = Transform(matrix: deviceAnchor.originFromAnchorTransform)
        }
    }
}
