import RealityKit

class Character {
    var entity: Entity
    var jumpLogic: CharacterJumpLogic
    var isJumping: Bool = false
    var basePosY: Float = 0.0

    init(entity: Entity, jumpLogic: CharacterJumpLogic, isJumping: Bool, basePosY: Float) {
        self.entity = entity
        self.jumpLogic = jumpLogic
        self.isJumping = isJumping
        self.basePosY = basePosY
    }
}
