import SwiftUI

class CharacterJumpLogic {

//    var isJumping: Bool = false

    private let downSpeedLimit: Int8 = 4
    private var jumpBtnPrevPress: Bool = false
    private var currentState: MovementState = .onGround

    private var verticalPositionOrigin: Int = 0
    private var verticalPosition: Int = 0
    private var verticalSpeed: Int = 0
    private var verticalForce: Int = 0
    private var verticalForceFall: Int = 0
    private var verticalForceDecimalPart: Int = 0
    private var correctionValue: Int = 0
    private var horizontalSpeed: Int = 0

    private let verticalForceDecimalPartData: [UInt8] = [0x20, 0x20, 0x1e, 0x28, 0x28]
    private let verticalFallForceData: [UInt8] = [0x70, 0x70, 0x60, 0x90, 0x90]
    private let initialVerticalSpeedData: [Int8] = [-4, -4, -4, -5, -5]
    private let initialVerticalForceData: [UInt8] = [0x00, 0x00, 0x00, 0x00, 0x00]

    enum MovementState {
        case onGround
        case jumping
    }

    init() {
        resetParam(initVerticalPos: 0)
    }

    var posY: Int {
        return verticalPosition
    }

    func resetParam(initVerticalPos: Int) {
        verticalSpeed = 0
        verticalForce = 0
        verticalForceFall = 0
        verticalForceDecimalPart = 0
        currentState = .onGround
        correctionValue = 0
        verticalPosition = initVerticalPos
    }

    func movement(jumpBtnPress: Bool) {
        jumpCheck(jumpBtnPress: jumpBtnPress)
        moveProcess(jumpBtnPress: jumpBtnPress)
        jumpBtnPrevPress = jumpBtnPress
    }

    private func jumpCheck(jumpBtnPress: Bool) {
        if !jumpBtnPress || jumpBtnPrevPress {
            return
        }

        if currentState == .onGround {
            preparingJump()
        }
    }

    private func preparingJump() {
        verticalForceDecimalPart = 0
        verticalPositionOrigin = verticalPosition

        currentState = .jumping

        var idx = 0
        if horizontalSpeed >= 0x1c {
            idx += 1
        }
        if horizontalSpeed >= 0x19 {
            idx += 1
        }
        if horizontalSpeed >= 0x10 {
            idx += 1
        }
        if horizontalSpeed >= 0x09 {
            idx += 1
        }

        verticalForce = Int(verticalForceDecimalPartData[idx])
        verticalForceFall = Int(verticalFallForceData[idx])
        verticalForceDecimalPart = Int(initialVerticalForceData[idx])
        verticalSpeed = Int(initialVerticalSpeedData[idx])
    }

    private func moveProcess(jumpBtnPress: Bool) {
        if verticalSpeed >= 0 {
            verticalForce = verticalForceFall
        } else {
            if !jumpBtnPress && jumpBtnPrevPress {
                if verticalPositionOrigin - verticalPosition >= 1 {
                    verticalForce = verticalForceFall
                }
            }
        }

        physics()
    }

    private func physics() {
        var cy = 0
        correctionValue += verticalForceDecimalPart
        if correctionValue >= 256 {
            correctionValue -= 256
            cy = 1
        }

        verticalPosition += verticalSpeed + cy
        verticalForceDecimalPart += verticalForce

        if verticalForceDecimalPart >= 256 {
            verticalForceDecimalPart -= 256
            verticalSpeed += 1
        }

        if verticalSpeed >= downSpeedLimit {
            if verticalForceDecimalPart >= 0x80 {
                verticalSpeed = Int(downSpeedLimit)
                verticalForceDecimalPart = 0x00
            }
        }
    }
}
