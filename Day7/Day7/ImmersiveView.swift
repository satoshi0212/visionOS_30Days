import SwiftUI
import RealityKit

struct ImmersiveView: View {

    @State var model = Day7ViewModel()
    @State var cube = Entity()

    var body: some View {
        RealityView { content in
            content.add(model.setupContentEntity())
            cube = model.addCube(name: "Cube1")
        }
        .gesture(
            SpatialTapGesture()
                .targetedToEntity(cube)
                .onEnded { value in
                    print(value)
                    Task {
                        do {
                            try await model.postToSlack(message: "Test message sent successfully!")
                        } catch {
                            print(error)
                        }
                    }
                }
        )
    }
}

#Preview {
    ImmersiveView()
        .previewLayout(.sizeThatFits)
}
