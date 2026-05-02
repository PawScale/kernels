import Foundation
import Metal

public class MetalCompute {
    public let device: MTLDevice
    public let commandQueue: MTLCommandQueue
    public let library: MTLLibrary

    public init(metalSource: String) {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is not supported on this device")
        }
        self.device = device

        guard let commandQueue = device.makeCommandQueue() else {
            fatalError("Could not create command queue")
        }
        self.commandQueue = commandQueue

        do {
            library = try device.makeLibrary(source: metalSource, options: nil)
        } catch {
            fatalError("Could not compile Metal library: \(error)")
        }
    }

    private func dispatch(
        kernelName: String,
        buffers: [MTLBuffer],
        threadCount: Int,
        threadgroupSize: Int = 32,
        threadgroupMemory: [Int] = []
    ) -> MTLBuffer {
        guard let function = library.makeFunction(name: kernelName) else {
            fatalError("Could not find kernel: \(kernelName)")
        }

        let pipeline = try! device.makeComputePipelineState(function: function)
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeComputeCommandEncoder() else {
            fatalError("Could not create command buffer or encoder")
        }

        encoder.setComputePipelineState(pipeline)
        for (index, buffer) in buffers.enumerated() {
            encoder.setBuffer(buffer, offset: 0, index: index)
        }
        for (index, memSize) in threadgroupMemory.enumerated() {
            encoder.setThreadgroupMemoryLength(memSize, index: index)
        }

        let threads = MTLSize(width: threadCount, height: 1, depth: 1)
        let tgroupSize = MTLSize(width: threadgroupSize, height: 1, depth: 1)
        encoder.dispatchThreads(threads, threadsPerThreadgroup: tgroupSize)
        encoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        return buffers.last!
    }

    private func dispatch2D(
        kernelName: String,
        buffers: [MTLBuffer],
        threadCount: (width: Int, height: Int),
        threadgroupSize: (width: Int, height: Int) = (8, 8),
        threadgroupMemory: [Int] = []
    ) -> MTLBuffer {
        guard let function = library.makeFunction(name: kernelName) else {
            fatalError("Could not find kernel: \(kernelName)")
        }

        let pipeline = try! device.makeComputePipelineState(function: function)
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeComputeCommandEncoder() else {
            fatalError("Could not create command buffer or encoder")
        }

        encoder.setComputePipelineState(pipeline)
        for (index, buffer) in buffers.enumerated() {
            encoder.setBuffer(buffer, offset: 0, index: index)
        }
        for (index, memSize) in threadgroupMemory.enumerated() {
            encoder.setThreadgroupMemoryLength(memSize, index: index)
        }

        let threads = MTLSize(width: threadCount.width, height: threadCount.height, depth: 1)
        let tgroupSize = MTLSize(width: threadgroupSize.width, height: threadgroupSize.height, depth: 1)
        encoder.dispatchThreads(threads, threadsPerThreadgroup: tgroupSize)
        encoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        return buffers.last!
    }

    public func arrayAddition(a: [Float], b: [Float]) -> [Float] {
        let count = a.count
        let bufferSize = count * MemoryLayout<Float>.size
        guard let aBuffer = device.makeBuffer(bytes: a, length: bufferSize),
              let bBuffer = device.makeBuffer(bytes: b, length: bufferSize),
              let resultBuffer = device.makeBuffer(length: bufferSize) else {
            fatalError("Could not create buffers")
        }
        _ = dispatch(kernelName: "add_arrays", buffers: [aBuffer, bBuffer, resultBuffer], threadCount: count)
        let resultPtr = resultBuffer.contents().assumingMemoryBound(to: Float.self)
        return Array(UnsafeBufferPointer(start: resultPtr, count: count))
    }

    public func arrayMultiply(a: [Float], b: [Float]) -> [Float] {
        let count = a.count
        let bufferSize = count * MemoryLayout<Float>.size
        guard let aBuffer = device.makeBuffer(bytes: a, length: bufferSize),
              let bBuffer = device.makeBuffer(bytes: b, length: bufferSize),
              let resultBuffer = device.makeBuffer(length: bufferSize) else {
            fatalError("Could not create buffers")
        }
        _ = dispatch(kernelName: "multiply_arrays", buffers: [aBuffer, bBuffer, resultBuffer], threadCount: count)
        let resultPtr = resultBuffer.contents().assumingMemoryBound(to: Float.self)
        return Array(UnsafeBufferPointer(start: resultPtr, count: count))
    }

    public func fusedMultiplyAdd(a: [Float], b: [Float], c: [Float]) -> [Float] {
        let count = a.count
        let bufferSize = count * MemoryLayout<Float>.size
        guard let aBuffer = device.makeBuffer(bytes: a, length: bufferSize),
              let bBuffer = device.makeBuffer(bytes: b, length: bufferSize),
              let cBuffer = device.makeBuffer(bytes: c, length: bufferSize),
              let resultBuffer = device.makeBuffer(length: bufferSize) else {
            fatalError("Could not create buffers")
        }
        _ = dispatch(kernelName: "fused_multiply_add", buffers: [aBuffer, bBuffer, cBuffer, resultBuffer], threadCount: count)
        let resultPtr = resultBuffer.contents().assumingMemoryBound(to: Float.self)
        return Array(UnsafeBufferPointer(start: resultPtr, count: count))
    }

    public func sumReduction(input: [Float]) -> [Float] {
        let count = input.count
        let bufferSize = count * MemoryLayout<Float>.size
        let outputSize = (count + 31) / 32 * MemoryLayout<Float>.size
        guard let inputBuffer = device.makeBuffer(bytes: input, length: bufferSize),
              let outputBuffer = device.makeBuffer(length: outputSize) else {
            fatalError("Could not create buffers")
        }
        _ = dispatch(kernelName: "sum_reduction", buffers: [inputBuffer, outputBuffer], threadCount: count, threadgroupSize: 32, threadgroupMemory: [32 * MemoryLayout<Float>.size])
        let resultPtr = outputBuffer.contents().assumingMemoryBound(to: Float.self)
        return Array(UnsafeBufferPointer(start: resultPtr, count: outputSize / MemoryLayout<Float>.size))
    }

    public func convolution2D(input: [Float], kernel: [Float], width: Int, height: Int) -> [Float] {
        let inputSize = input.count * MemoryLayout<Float>.size
        let kernelSize = kernel.count * MemoryLayout<Float>.size
        guard let inputBuffer = device.makeBuffer(bytes: input, length: inputSize),
              let kernelBuffer = device.makeBuffer(bytes: kernel, length: kernelSize),
              let outputBuffer = device.makeBuffer(length: inputSize),
              let widthBuffer = device.makeBuffer(bytes: [UInt32(width)], length: MemoryLayout<UInt32>.size),
              let heightBuffer = device.makeBuffer(bytes: [UInt32(height)], length: MemoryLayout<UInt32>.size) else {
            fatalError("Could not create buffers")
        }
        _ = dispatch2D(kernelName: "convolution_2d", buffers: [inputBuffer, kernelBuffer, outputBuffer, widthBuffer, heightBuffer], threadCount: (width, height), threadgroupSize: (8, 8))
        let resultPtr = outputBuffer.contents().assumingMemoryBound(to: Float.self)
        return Array(UnsafeBufferPointer(start: resultPtr, count: input.count))
    }

    public func matrixMultiply(a: [Float], b: [Float], size: Int) -> [Float] {
        let bufferSize = size * size * MemoryLayout<Float>.size
        guard let aBuffer = device.makeBuffer(bytes: a, length: bufferSize),
              let bBuffer = device.makeBuffer(bytes: b, length: bufferSize),
              let cBuffer = device.makeBuffer(length: bufferSize),
              let kBuffer = device.makeBuffer(bytes: [UInt32(size)], length: MemoryLayout<UInt32>.size) else {
            fatalError("Could not create buffers")
        }
        _ = dispatch2D(kernelName: "matrix_multiply", buffers: [aBuffer, bBuffer, cBuffer, kBuffer], threadCount: (size, size), threadgroupSize: (8, 8))
        let resultPtr = cBuffer.contents().assumingMemoryBound(to: Float.self)
        return Array(UnsafeBufferPointer(start: resultPtr, count: size * size))
    }

    public func softmax(input: [Float]) -> [Float] {
        let count = input.count
        let bufferSize = count * MemoryLayout<Float>.size
        guard let inputBuffer = device.makeBuffer(bytes: input, length: bufferSize),
              let outputBuffer = device.makeBuffer(length: bufferSize),
              let nBuffer = device.makeBuffer(bytes: [UInt32(count)], length: MemoryLayout<UInt32>.size) else {
            fatalError("Could not create buffers")
        }
        _ = dispatch(kernelName: "softmax", buffers: [inputBuffer, outputBuffer, nBuffer], threadCount: count)
        let resultPtr = outputBuffer.contents().assumingMemoryBound(to: Float.self)
        return Array(UnsafeBufferPointer(start: resultPtr, count: count))
    }

    public func exclusiveScan(input: [Float]) -> [Float] {
        let count = input.count
        let bufferSize = count * MemoryLayout<Float>.size
        guard let inputBuffer = device.makeBuffer(bytes: input, length: bufferSize),
              let outputBuffer = device.makeBuffer(length: bufferSize) else {
            fatalError("Could not create buffers")
        }
        _ = dispatch(kernelName: "exclusive_scan", buffers: [inputBuffer, outputBuffer], threadCount: count, threadgroupSize: 32, threadgroupMemory: [32 * MemoryLayout<Float>.size])
        let resultPtr = outputBuffer.contents().assumingMemoryBound(to: Float.self)
        return Array(UnsafeBufferPointer(start: resultPtr, count: count))
    }

    public func sigmoid(_ input: [Float]) -> [Float] {
        let count = input.count
        let bufferSize = count * MemoryLayout<Float>.size
        guard let inputBuffer = device.makeBuffer(bytes: input, length: bufferSize),
              let outputBuffer = device.makeBuffer(length: bufferSize) else {
            fatalError("Could not create buffers")
        }
        _ = dispatch(kernelName: "sigmoid", buffers: [inputBuffer, outputBuffer], threadCount: count)
        let resultPtr = outputBuffer.contents().assumingMemoryBound(to: Float.self)
        return Array(UnsafeBufferPointer(start: resultPtr, count: count))
    }

    public func tanh(_ input: [Float]) -> [Float] {
        let count = input.count
        let bufferSize = count * MemoryLayout<Float>.size
        guard let inputBuffer = device.makeBuffer(bytes: input, length: bufferSize),
              let outputBuffer = device.makeBuffer(length: bufferSize) else {
            fatalError("Could not create buffers")
        }
        _ = dispatch(kernelName: "tanh_activation", buffers: [inputBuffer, outputBuffer], threadCount: count)
        let resultPtr = outputBuffer.contents().assumingMemoryBound(to: Float.self)
        return Array(UnsafeBufferPointer(start: resultPtr, count: count))
    }

    public func gelu(_ input: [Float]) -> [Float] {
        let count = input.count
        let bufferSize = count * MemoryLayout<Float>.size
        guard let inputBuffer = device.makeBuffer(bytes: input, length: bufferSize),
              let outputBuffer = device.makeBuffer(length: bufferSize) else {
            fatalError("Could not create buffers")
        }
        _ = dispatch(kernelName: "gelu", buffers: [inputBuffer, outputBuffer], threadCount: count)
        let resultPtr = outputBuffer.contents().assumingMemoryBound(to: Float.self)
        return Array(UnsafeBufferPointer(start: resultPtr, count: count))
    }

    public func depthwiseConv2D(input: [Float], weights: [Float], bias: [Float], channels: Int, kernelSize: Int, inputSize: Int) -> [Float] {
        let outputSize = (inputSize - kernelSize + 1) * (inputSize - kernelSize + 1) * channels
        guard let inputBuffer = device.makeBuffer(bytes: input, length: input.count * MemoryLayout<Float>.size),
              let weightsBuffer = device.makeBuffer(bytes: weights, length: weights.count * MemoryLayout<Float>.size),
              let biasBuffer = device.makeBuffer(bytes: bias, length: bias.count * MemoryLayout<Float>.size),
              let outputBuffer = device.makeBuffer(length: outputSize * MemoryLayout<Float>.size),
              let channelsBuffer = device.makeBuffer(bytes: [UInt32(channels)], length: MemoryLayout<UInt32>.size),
              let kernelSizeBuffer = device.makeBuffer(bytes: [UInt32(kernelSize)], length: MemoryLayout<UInt32>.size),
              let inputSizeBuffer = device.makeBuffer(bytes: [UInt32(inputSize)], length: MemoryLayout<UInt32>.size) else {
            fatalError("Could not create buffers")
        }
        let outputDim = inputSize - kernelSize + 1
        _ = dispatch2D(kernelName: "depthwise_conv2d", buffers: [inputBuffer, weightsBuffer, biasBuffer, outputBuffer, channelsBuffer, kernelSizeBuffer, inputSizeBuffer], threadCount: (outputDim, outputDim), threadgroupSize: (8, 8))
        let resultPtr = outputBuffer.contents().assumingMemoryBound(to: Float.self)
        return Array(UnsafeBufferPointer(start: resultPtr, count: outputSize))
    }

    public func batchedMatmul(a: [Float], b: [Float], batchSize: Int, m: Int, k: Int, n: Int) -> [Float] {
        let cSize = batchSize * m * n
        guard let aBuffer = device.makeBuffer(bytes: a, length: a.count * MemoryLayout<Float>.size),
              let bBuffer = device.makeBuffer(bytes: b, length: b.count * MemoryLayout<Float>.size),
              let cBuffer = device.makeBuffer(length: cSize * MemoryLayout<Float>.size),
              let batchBuffer = device.makeBuffer(bytes: [UInt32(batchSize)], length: MemoryLayout<UInt32>.size),
              let mBuffer = device.makeBuffer(bytes: [UInt32(m)], length: MemoryLayout<UInt32>.size),
              let kBuffer = device.makeBuffer(bytes: [UInt32(k)], length: MemoryLayout<UInt32>.size),
              let nBuffer = device.makeBuffer(bytes: [UInt32(n)], length: MemoryLayout<UInt32>.size) else {
            fatalError("Could not create buffers")
        }
        _ = dispatch(kernelName: "matmul_batched", buffers: [aBuffer, bBuffer, cBuffer, batchBuffer, mBuffer, kBuffer, nBuffer], threadCount: cSize, threadgroupSize: 256)
        let resultPtr = cBuffer.contents().assumingMemoryBound(to: Float.self)
        return Array(UnsafeBufferPointer(start: resultPtr, count: cSize))
    }
}
