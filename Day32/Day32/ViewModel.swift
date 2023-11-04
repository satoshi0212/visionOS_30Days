import SwiftUI
import RealityKit
import AVFoundation
import Observation
import Combine

@Observable
class ViewModel {

    private var contentEntity = Entity()
    private var audioPlayer: AVAudioPlayer?
    private var characters: [String: Character] = [:]

    private let timer = Timer.publish(every: 1.0/60.0, on: .main, in: .common)
    private var cancellables = Set<AnyCancellable>()

    func configure() {
        // Jump
        timer
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.processJump()
            }
            .store(in: &cancellables)

        // Sound
        if let soundURL = Bundle.main.url(forResource: "se_jump_001", withExtension: "wav") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.prepareToPlay()
            } catch {
                print("Error playing sound: \(error)")
            }
        }
    }

    func close() {
        cancellables.removeAll()
        audioPlayer = nil
        characters.values.forEach { $0.entity.removeFromParent() }
        characters.removeAll()
    }

    func setupContentEntity() -> Entity {
        return contentEntity
    }

    func addCube(name: String, posision: SIMD3<Float>, color: UIColor) {
        let entity = ModelEntity(
            mesh: .generateBox(size: 0.2, cornerRadius: 0),
            materials: [SimpleMaterial(color: color, isMetallic: false)],
            collisionShape: .generateBox(size: SIMD3<Float>(repeating: 0.2)),
            mass: 0.0
        )

        entity.name = name
        entity.position = posision
        entity.components.set(InputTargetComponent(allowedInputTypes: .indirect))
        entity.components.set(CollisionComponent(shapes: [ShapeResource.generateBox(size: SIMD3<Float>(repeating: 0.2))], isStatic: true))
        entity.components.set(HoverEffectComponent())

        contentEntity.addChild(entity)
        characters[name] = Character(entity: entity, jumpLogic: CharacterJumpLogic(), isJumping: false, basePosY: posision.y)
    }

    func playAnimation(entity: Entity, isHighJump: Bool) {

        guard let character = characters[entity.name] else { return }

        let durationOffset = isHighJump ? 0.5 : 0.2
        character.isJumping = true
        playSound()
        DispatchQueue.main.asyncAfter(deadline: .now() + durationOffset) {
            character.isJumping = false
        }
    }

    // MARK: - Private

    private func processJump() {
        for character in characters.values {
            character.jumpLogic.movement(jumpBtnPress: character.isJumping)
            if character.jumpLogic.posY > 0 {
                character.jumpLogic.resetParam(initVerticalPos: 0)
            }

            var translation = character.entity.transform.translation
            translation.y = character.basePosY + -0.01 * Float(character.jumpLogic.posY)
            character.entity.transform.translation = translation
        }
    }

    private func playSound() {
        audioPlayer?.play()
    }
}
