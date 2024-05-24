import SwiftUI
import RealityKit
import AVFoundation

struct ImmersiveView: View {

    var body: some View {
        RealityView { content in

            let avPlayer = AVPlayer()

            let url = Bundle.main.url(forResource: "ayutthaya", withExtension: "mp4")!
            let asset = AVAsset(url: url)
            let playerItem = AVPlayerItem(asset: asset)

            let material = VideoMaterial(avPlayer: avPlayer)

            let videoEntity = Entity()
            videoEntity.components.set(ModelComponent(mesh: .generateSphere(radius: 1E3), materials: [material]))
            videoEntity.scale *= SIMD3(-1, 1, 1)
            videoEntity.orientation *= simd_quatf(angle: .pi / 2, axis: [0, 1, 0])

            content.add(videoEntity)

            avPlayer.replaceCurrentItem(with: playerItem)
            avPlayer.play()
        }
    }
}
