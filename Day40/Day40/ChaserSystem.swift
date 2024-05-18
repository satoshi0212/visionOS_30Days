import RealityKit

enum ChaserState {
    case idle
    case chase
    case circle
}

struct ChaserComponent: Component {
    var state: ChaserState = .idle
    var chaseSpeed: Float = 0.0
    var circleSpeed: Float = 0.0
    var axis: SIMD3<Float>
    weak var orbit: Entity?
    weak var placeHolder: Entity?

    init(chaseSpeed: Float, circleSpeed: Float, axis: SIMD3<Float> = [0, 1, 0], orbit: Entity?, placeHolder: Entity?) {
        self.chaseSpeed = chaseSpeed
        self.circleSpeed = circleSpeed
        self.axis = axis
        self.orbit = orbit
        self.placeHolder = placeHolder
    }
}

class ChaserSystem : System {
    static let query = EntityQuery(where: .has(ChaserComponent.self))

    required init(scene: RealityKit.Scene) {}

    func update(context: SceneUpdateContext) {
        
        let targetPosition = getTargetPosition(context: context)

        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            var chaser: ChaserComponent = entity.components[ChaserComponent.self]!
            defer { entity.components[ChaserComponent.self] = chaser }

            let entityPosition = SIMD3<Float>(entity.position.x, entity.position.y, entity.position.z)
            let distance = length(targetPosition - entityPosition)

            chaser.state = reCalcState(chaser: chaser, distance: distance)

            switch chaser.state {
            case .idle:
                break
            case .chase:
                let direction = normalize(entityPosition - targetPosition)
                let movement = direction * chaser.chaseSpeed
                entity.position -= movement
                if let placeHolder = chaser.placeHolder {
                    placeHolder.look(at: targetPosition,
                                     from: placeHolder.position(relativeTo: nil),
                                     relativeTo: nil,
                                     forward: .positiveZ)
                }
                (entity as? BirdEntity)?.stopAudio()
            case .circle:
                if let orbit = chaser.orbit {
                    orbit.setOrientation(.init(angle: chaser.circleSpeed * Float(context.deltaTime), axis: chaser.axis), relativeTo: orbit)
                    chaser.placeHolder?.orientation = .init(angle: .pi / 2, axis: [0, 1, 0])
                }
                (entity as? BirdEntity)?.playAudio()
            }
        }
    }

    private func getTargetPosition(context: SceneUpdateContext) -> SIMD3<Float> {
        guard let device = context.entities(matching: DeviceSystem.query, updatingSystemWhen: .rendering).first(where: { _ in true }) else { return .zero }
        let deviceTransform = device.transform
        let translation = matrix_identity_float4x4
        let targetTransform = simd_mul(deviceTransform.matrix, translation)
        return SIMD3<Float>(targetTransform.columns.3.x, targetTransform.columns.3.y, targetTransform.columns.3.z)
    }

    private func reCalcState(chaser: ChaserComponent, distance: Float) -> ChaserState {
        if (chaser.state != .circle && distance > Constants.Chaser.moveRadius) || (chaser.state == .circle && distance > Constants.Chaser.circleThreshold) {
            return .chase
        }

        if (chaser.state != .circle && distance <= Constants.Chaser.moveRadius) {
            return .circle
        }

        return chaser.state
    }
}
