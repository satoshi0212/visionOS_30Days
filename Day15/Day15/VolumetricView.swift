import SwiftUI
import RealityKit

struct VolumetricView: View {

    @Environment(ViewModel.self) private var model

    var body: some View {
        VStack {
            Model3D(url: model.selectedType.url) { model in
                model
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                ProgressView()
            }
            .onDisappear {
                model.isShowing = false
            }
        }
    }
}

#Preview {
    VolumetricView()
        .environment(ViewModel())
}
