import RealityKit
import Observation
import AVFoundation

@Observable
class ViewModel {

    private var contentEntity = Entity()
    private let avPlayer = AVPlayer()

    func setupContentEntity() -> Entity {
        setupAvPlayer()
        let material = VideoMaterial(avPlayer: avPlayer)

        let sphere = try! Entity.load(named: "Sphere")
        sphere.scale = .init(x: 1E3, y: 1E3, z: 1E3)

        let modelEntity = sphere.children[0].children[0] as! ModelEntity
        modelEntity.model?.materials = [material]

        contentEntity.addChild(sphere)
        contentEntity.scale *= .init(x: -1, y: 1, z: 1)

        return contentEntity
    }

    func play() {
        avPlayer.play()
    }

    func pause() {
        avPlayer.pause()
    }

    private func setupAvPlayer() {
        let url = Bundle.main.url(forResource: "ayutthaya", withExtension: "mp4")
        let asset = AVAsset(url: url!)
        let playerItem = AVPlayerItem(asset: asset)
        avPlayer.replaceCurrentItem(with: playerItem)
    }
}
