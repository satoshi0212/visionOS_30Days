import SwiftUI

struct ContentView: View {

    @Environment(ViewModel.self) var viewModel

    var body: some View {
        VStack(alignment: .center) {
            MetalView()
                .environment(viewModel)
                .frame(width: Constants.targetSize.width, height: Constants.targetSize.height)
                .task {
                    viewModel.updateResolution(width: Float(Constants.targetSize.width), height: Float(Constants.targetSize.height))
                }
        }
    }
}

struct MetalView: UIViewRepresentable {
    typealias UIViewType = UIView

    @Environment(ViewModel.self) var viewModel

    func makeUIView(context: Context) -> UIView {
        let view = MetalLayerView(frame: CGRect(origin: .zero, size: Constants.targetSize))
        view.backgroundColor = .clear
        view.isOpaque = false

        if let layer = view.layer as? CAMetalLayer {
            layer.pixelFormat = .bgra8Unorm
            layer.frame = view.frame
            layer.drawableSize = view.bounds.size
            layer.isOpaque = false
            layer.backgroundColor = CGColor(red: 0, green: 0, blue: 0, alpha: 0)
            viewModel.setDrawTarget(metalLayer: layer)
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {

    }
}

class MetalLayerView: UIView {
    override class var layerClass: AnyClass {
        return CAMetalLayer.self
    }
}
