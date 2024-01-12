import SwiftUI
import RealityKit
import ARKit

struct ImmersiveView: View {

    @Environment(ViewModel.self) private var viewModel

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
        .gesture(
            SpatialTapGesture(count: 2)
                .targetedToAnyEntity()
                .onEnded { value in
                    let timerView = TimerView()
                    timerViews.append(timerView)
                    let entity = viewModel.addSpatialPlaceholder(name: timerView.id.uuidString, value: nil)
                    let matrix = arkitSessionManager.getOriginFromDeviceTransform()
                    viewModel.setEntityPosition(entity: entity, matrix: matrix)
                }
        )
        .gesture(
            LongPressGesture(minimumDuration: 1.0)
                .targetedToAnyEntity()
                .onEnded { _ in
                    viewModel.showImmersiveSpace.toggle()
                }
        )
    }
}

#Preview {
    ImmersiveView()
        .environment(ViewModel())
        .previewLayout(.sizeThatFits)
}
