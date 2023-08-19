import SwiftUI

struct SwiftUISampleView: View {

    var viewModel = ViewModel()

    var body: some View {
        viewToSnapshot()
        .task {
            await generateSnapshot()
        }
    }

    func viewToSnapshot() -> some View {
        VStack {
            GeometryReader { geometry in
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.pink)
                    .overlay(
                        VStack {
                            Text("Source SwiftUI View")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                            Text("X: \(geometry.frame(in: .global).origin.x) Y: \(geometry.frame(in: .global).origin.y) width: \(geometry.frame(in: .global).width) height: \(geometry.frame(in: .global).height)")
                                .foregroundColor(.white)
                        }
                    )
            }
        }
        .frame(width: targetSize.width, height: targetSize.height)
    }

    @MainActor
    func generateSnapshot() async {
        let renderer = ImageRenderer(content: viewToSnapshot())
        if let image = renderer.uiImage {
            viewModel.targetSnapshot = image
        }
    }
}
