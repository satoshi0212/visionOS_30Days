import SwiftUI
//import RealityKit
//import Observation

extension simd_float4x4 {

    var position: SIMD3<Float> {
        SIMD3<Float>(self.columns.3.x, self.columns.3.y, self.columns.3.z)
    }

    var rotation: simd_quatf {
        let x = simd_float3(self.columns.0.x, self.columns.0.y, self.columns.0.z)
        let y = simd_float3(self.columns.1.x, self.columns.1.y, self.columns.1.z)
        let z = simd_float3(self.columns.2.x, self.columns.2.y, self.columns.2.z)

        let scaleX = simd_length(x)
        let scaleY = simd_length(y)
        let scaleZ = simd_length(z)

        let sign = simd_sign(self.columns.0.x * self.columns.1.y * self.columns.2.z +
                             self.columns.0.y * self.columns.1.z * self.columns.2.x +
                             self.columns.0.z * self.columns.1.x * self.columns.2.y -
                             self.columns.0.z * self.columns.1.y * self.columns.2.x -
                             self.columns.0.y * self.columns.1.x * self.columns.2.z -
                             self.columns.0.x * self.columns.1.z * self.columns.2.y)

        let rotationMatrix = simd_float3x3(x / scaleX, y / scaleY, z / scaleZ)
        let quaternion = simd_quaternion(rotationMatrix)

        return sign >= 0 ? quaternion : -quaternion
    }
}
