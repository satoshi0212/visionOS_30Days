import SwiftUI
import RealityKit

struct ImmersiveView: View {

    @State var model = ViewModel()

    var body: some View {
        RealityView { content in
            content.add(model.setupContentEntity())
        }
        .gesture(
            SpatialTapGesture(count: 2)
                .targetedToAnyEntity()
                .onEnded { value in
                    model.addAxis(value: value)
                }
        )
    }
}

#Preview {
    ImmersiveView()
        .previewLayout(.sizeThatFits)
}
