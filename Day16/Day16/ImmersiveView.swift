import SwiftUI
import RealityKit
import ARKit

struct ImmersiveView: View {

    @State var model = ViewModel()

    @ObservedObject var arkitSessionManager = ARKitSessionManager()
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        RealityView { content in
            content.add(model.setupContentEntity())
        }
        .task {
            await arkitSessionManager.startSession()
        }
        .task {
            await arkitSessionManager.handleWorldTrackingUpdates()
        }
        .task {
            await arkitSessionManager.monitorSessionEvent()
        }
        .onReceive(timer) { _ in
            arkitSessionManager.reportDevicePose()
        }
        .gesture(
            SpatialTapGesture(count: 2)
                .targetedToAnyEntity()
                .onEnded { _ in
                    let matrix = arkitSessionManager.getOriginFromDeviceTransform()
                    model.addAxis(matrix: matrix)
                }
        )
    }
}

#Preview {
    ImmersiveView()
        .previewLayout(.sizeThatFits)
}
