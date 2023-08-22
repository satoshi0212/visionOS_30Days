import SwiftUI
import RealityKit
import ARKit

struct ImmersiveView: View {

    var viewModel: ViewModel

    @ObservedObject var arkitSessionManager = ARKitSessionManager()
    @State var timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        _logView = State(initialValue: LogView(viewModel: viewModel))
    }

    @State private var logView: LogView!

    var body: some View {
        RealityView { content, attachments in
            content.add(viewModel.setupContentEntity())

            // LogView
            let entity = viewModel.addNull(name: logView.id.uuidString, value: nil)
            let matrix = arkitSessionManager.getOriginFromDeviceTransform()
            entity.position = matrix.position
            entity.orientation = matrix.rotation

            if let attachment = attachments.entity(for: logView.id) {
                if let parent = viewModel.getTargetEntity(name: logView.id.uuidString) {
                    attachment.position = [0, 0, 0]
                    parent.addChild(attachment)
                }
            }

            // Tap target cubes
            _ = viewModel.addCube(name: UUID().uuidString, posision: SIMD3(x: 1, y: 1, z: -2), color: .red)
            _ = viewModel.addCube(name: UUID().uuidString, posision: SIMD3(x: -1, y: 1.5, z: -4), color: .blue)
            _ = viewModel.addCube(name: UUID().uuidString, posision: SIMD3(x: 1.5, y: 0.5, z: -3), color: .green)
        } update: { content, attachments in

        } attachments: {
            logView
                .tag(logView.id)
        }
        .task {
            await arkitSessionManager.startSession()
        }
        .onReceive(timer) { _ in
            // re-position LogView
            if let entity = viewModel.getTargetEntity(name: logView.id.uuidString) {
                let matrix = arkitSessionManager.getOriginFromDeviceTransform()
                entity.position = matrix.calculateLookAtPoint(from: matrix, distance: -0.5, yOffset: 0.08)
                entity.orientation = matrix.rotation
            }

//            Task {
//                await viewModel.addMessage(arkitSessionManager.getPoseLog())
//            }
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    guard let entity = viewModel.getTargetEntity(name: value.entity.name) as? ModelEntity else { return  }
                    Task {
                        await viewModel.addMessage("Tapped: \(entity.tintColorName) \(entity.name)")
                    }
                }
        )
        .onDisappear {
            arkitSessionManager.stopSession()
        }
    }
}

#Preview {
    ImmersiveView(viewModel: ViewModel())
        .previewLayout(.sizeThatFits)
}
