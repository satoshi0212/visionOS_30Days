import SwiftUI
import RealityKit
import Metal

struct ContentView: View {

    var body: some View {
        VStack {
            MetalLayerView()
                .frame(width: 640, height: 360)
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}

struct MetalLayerView: UIViewRepresentable {
    func makeUIView(context: Context) -> some UIView { BaseMetalLayerView() }
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

class BaseMetalLayerView: UIView {

    private var displaylink: CADisplayLink?
    private var metalLayer: CAMetalLayer

    private var device: MTLDevice
    private var renderPassDescriptor: MTLRenderPassDescriptor
    private var commandQueue: MTLCommandQueue
    private var renderPipelineState: MTLRenderPipelineState
    private var lockFlag = false

    private let vertexData: [[Float]] = [
        [
            -1, -1, 0, 1,
             1, -1, 0, 1,
            -1,  1, 0, 1,
             1,  1, 0, 1,
        ],
    ]

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init() {
        metalLayer = CAMetalLayer()
        device = MTLCreateSystemDefaultDevice()!
        renderPassDescriptor = MTLRenderPassDescriptor()
        commandQueue = device.makeCommandQueue()!

        let library = device.makeDefaultLibrary()!
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertexShader")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragmentShader")
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderPipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDescriptor)

        super.init(frame: .zero)

        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1)

        metalLayer.device = device

        createDisplayLink()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        metalLayer.frame = layer.frame
        layer.addSublayer(metalLayer)
    }

    private func createDisplayLink() {
        guard self.displaylink == nil else { return }
        let displaylink = CADisplayLink(target: self, selector: #selector(render))
        displaylink.add(to: .current, forMode: .default)
        self.displaylink = displaylink
    }

    @objc
    private func render() {
        if lockFlag { return }
        lockFlag = true

        guard let drawable = metalLayer.nextDrawable(),
              let commandBuffer = commandQueue.makeCommandBuffer() else { return }

        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        encoder.setRenderPipelineState(renderPipelineState)

        vertexData.enumerated().forEach { i, array in
            let size = array.count * MemoryLayout.size(ofValue: array[0])
            let buffer = device.makeBuffer(bytes: array, length: size)
            encoder.setVertexBuffer(buffer, offset: 0, index: i)
        }

        encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: vertexData[0].count / 4)

        encoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()

        lockFlag = false
    }
}
