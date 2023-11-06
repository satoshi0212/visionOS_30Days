import SwiftUI
import RealityKit

struct ImmersiveView: View {

    @Environment(PlaneDetectionModel.self) var model

    var body: some View {
        RealityView { content in
            content.add(model.setupContentEntity())
        }
        .task {
            await model.runSession()
        }
        .task {
            await model.processPlaneDetectionUpdates()
        }
        .task {
            await model.monitorSessionEvents()
        }
    }
}

#Preview {
    ImmersiveView()
        .previewLayout(.sizeThatFits)
        .environment(PlaneDetectionModel())
}
