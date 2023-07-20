import RealityKit
import Observation

@Observable
class ViewModel {

    var cubeEntity: ModelEntity? = nil
    
    var isTransparent: Bool = false
    var selectedScale: Scales = .medium

    var simpleMaterial: RealityKit.Material {
        let texture1 = try! TextureResource.load(named: "Slack_icon")
        var simpleMaterial = SimpleMaterial()
        simpleMaterial.color = .init(tint: .white ,texture: .init(texture1))
        return simpleMaterial
    }

    var unlitMaterial: RealityKit.Material {
        let texture1 = try! TextureResource.load(named: "Slack_icon")
        var unlitMaterial = UnlitMaterial()
        unlitMaterial.color = .init(tint: .white, texture: .init(texture1))
        unlitMaterial.blending = .transparent(opacity: PhysicallyBasedMaterial.Opacity(floatLiteral: 1.0))
        return unlitMaterial
    }

    func updateTransparency() {
        if let cubeEntity = cubeEntity {
            let materials = isTransparent ? [unlitMaterial] : [simpleMaterial]
            cubeEntity.model?.materials = materials
        }
    }

    func updateScale() {
        if let cubeEntity = cubeEntity {
            let newScale = selectedScale.scaleValue
            cubeEntity.setScale(SIMD3<Float>(repeating: newScale), relativeTo: nil)
        }
    }
}

enum Scales: String, CaseIterable, Identifiable {
    case verySmall, small, medium, large, veryLarge
    var id: Self { self }

    var name: String {
        switch self {
        case .verySmall: "Very small"
        case .small: "Small"
        case .medium: "Medium"
        case .large: "Large"
        case .veryLarge: "Very large"
        }
    }

    var scaleValue: Float {
        switch self {
        case .verySmall: 0.3
        case .small: 0.5
        case .medium: 1.0
        case .large: 1.5
        case .veryLarge: 1.8
        }
    }
}
