import SwiftUI
import RealityKit

extension ModelEntity {

    var tintColorName: String {
        guard let material = self.model?.materials.first as? SimpleMaterial else { return UIColor.black.accessibilityName }
        return material.color.tint.accessibilityName
    }
}
