import SwiftUI
import RealityKit
import ARKit

struct ImmersiveView: View {

    @Environment(ViewModel.self) private var model

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
        .gesture(
            LongPressGesture(minimumDuration: 1.0)
                .targetedToAnyEntity()
                .onEnded { _ in
                    model.showImmersiveSpace.toggle()
                }
        )
    }
}

#Preview {
    ImmersiveView()
        .environment(ViewModel())
        .previewLayout(.sizeThatFits)
}
