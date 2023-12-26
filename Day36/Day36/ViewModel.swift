import MetalKit
import Observation

@Observable
class ViewModel: NSObject {

    private static let maxBuffersInFlight: Int = 3

    private var metalLayer: CAMetalLayer!

    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let pipelineState: MTLRenderPipelineState
    private let renderPassDescriptor: MTLRenderPassDescriptor
    private let videoTextureCache: CVMetalTextureCache

    private let startDate = Date()
    private let semaphore = DispatchSemaphore(value: 1)
    private var rustyMetalTexture: MTLTexture! = nil
    private var resolutionBuffer: MTLBuffer! = nil
    private var timeBuffer : MTLBuffer! = nil

    private var displaylink: CADisplayLink?

    init(colorPixelFormat: MTLPixelFormat) {

        device = MTLCreateSystemDefaultDevice()!
        commandQueue = device.makeCommandQueue(maxCommandBufferCount: Self.maxBuffersInFlight)!

        let library = device.makeDefaultLibrary()!
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertexShader")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragmentShader")
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        pipelineDescriptor.colorAttachments[0].pixelFormat = colorPixelFormat
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDescriptor)

        renderPassDescriptor = MTLRenderPassDescriptor()

        var textureCache: CVMetalTextureCache!
        CVMetalTextureCacheCreate(nil, nil, device, nil, &textureCache)
        videoTextureCache = textureCache

        super.init()

        resolutionBuffer = device.makeBuffer(length: 2 * MemoryLayout<Float>.size, options: [])
        timeBuffer = device.makeBuffer(length: MemoryLayout<Float>.size, options: [])
        rustyMetalTexture = loadTexture(image: UIImage(named: "MetalTexture")!, rect: CGRect(x: 0, y: 0, width: 512, height: 512))

        createDisplayLink()
    }

    func setDrawTarget(metalLayer: CAMetalLayer) {
        metalLayer.device = device
        self.metalLayer = metalLayer
    }

    func updateResolution(width: Float, height: Float) {
        memcpy(resolutionBuffer.contents(), [width, height], MemoryLayout<Float>.size * 2)
    }

    private func createDisplayLink() {
        guard self.displaylink == nil else { return }
        let displaylink = CADisplayLink(target: self, selector: #selector(step))
        displaylink.preferredFrameRateRange = .init(minimum: 10, maximum: 30, preferred: 30)
        displaylink.add(to: .current, forMode: .default)
        self.displaylink = displaylink
    }

    @objc private func step(displaylink: CADisplayLink) {
        guard let metalLayer = self.metalLayer else { return }
        autoreleasepool {
            draw(in: metalLayer)
        }
    }

    private func loadTexture(image: UIImage, rect: CGRect) -> MTLTexture {
        let textureLoader = MTKTextureLoader(device: device)
        let imageRef = image.cgImage!.cropping(to: rect)!
        let imageData = UIImage(cgImage: imageRef).pngData()!
        return try! textureLoader.newTexture(data: imageData, options: nil)
    }
}

extension ViewModel {

    private func updateTime(_ time: Float) {
        updateBuffer(time, timeBuffer)
    }

    private func updateBuffer<T>(_ data:T, _ buffer: MTLBuffer) {
        let pointer = buffer.contents()
        let value = pointer.bindMemory(to: T.self, capacity: 1)
        value[0] = data
    }

    func draw(in layer: CAMetalLayer) {
        _ = semaphore.wait(timeout: .distantFuture)

        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        guard let currentDrawable = layer.nextDrawable() else { return }

        renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadAction.clear
        renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreAction.store
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 0)
        renderPassDescriptor.colorAttachments[0].texture = currentDrawable.texture

        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }

        updateTime(Float(Date().timeIntervalSince(startDate)))

        renderEncoder.setRenderPipelineState(pipelineState)

        renderEncoder.setFragmentBuffer(resolutionBuffer, offset: 0, index: 0)
        renderEncoder.setFragmentBuffer(timeBuffer, offset: 0, index: 1)

        renderEncoder.setFragmentTexture(rustyMetalTexture, index: 0)

        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder.endEncoding()

        commandBuffer.addScheduledHandler { [weak self] (_) in
            guard let self = self else { return }
            self.semaphore.signal()
        }

        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
    }
}
