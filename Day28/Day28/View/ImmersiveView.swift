import SwiftUI
import RealityKit
import ARKit

struct ImmersiveView: View {

    var viewModel: ViewModel
    
    @ObservedObject var arkitSessionManager = ARKitSessionManager()
    @State private var timerViews: [TimerView] = []

    var body: some View {
        RealityView { content, attachments in
            content.add(viewModel.setupContentEntity())
        } update: { content, attachments in
            for timerView in timerViews {
                if let attachment = attachments.entity(for: timerView.id) {
                    if let parent = viewModel.getTargetEntity(name: timerView.id.uuidString) {
                        attachment.position = [0, 0, 0]
                        parent.addChild(attachment)
                    }
                }
            }
        } attachments: {
            ForEach(timerViews) { timerView in
                Attachment(id: timerView.id) {
                    timerView
                }
            }
        }
        .task {
            await arkitSessionManager.startSession()
        }
        .onDisappear {
            arkitSessionManager.stopSession()
        }
        .gesture(
            SpatialTapGesture(count: 2)
                .targetedToAnyEntity()
                .onEnded { value in
                    let timerView = TimerView()
                    timerViews.append(timerView)

                    let entity = viewModel.addNull(name: timerView.id.uuidString, value: nil)
                    let matrix = arkitSessionManager.getOriginFromDeviceTransform()
                    entity.position = matrix.position
                    entity.orientation = matrix.rotation
                }
        )
    }
}

#Preview {
    ImmersiveView(viewModel: ViewModel())
        .previewLayout(.sizeThatFits)
}
