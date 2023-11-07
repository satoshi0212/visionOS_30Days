import SwiftUI
import RealityKit

struct ImmersiveView: View {

    @Environment(ImageTrackingModel.self) var model

    var body: some View {
        RealityView { content in
            content.add(model.setupContentEntity())
        }
        .task {
            await model.runSession()
        }
        .task {
            await model.processImageTrackingUpdates()
        }
        .task {
            await model.monitorSessionEvents()
        }
    }
}

#Preview {
    ImmersiveView()
        .previewLayout(.sizeThatFits)
        .environment(ImageTrackingModel())
}
