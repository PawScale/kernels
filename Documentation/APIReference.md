# API Reference

## MetalKernel

Main class for executing Metal compute kernels.

### Initialization

```swift
init(name: String)
```

Initializes a Metal kernel with the given name.

- **Parameters:**
  - `name`: The name of the kernel function in your Metal library

### Methods

#### execute

```swift
func execute(inputs: [Data], gridSize: (Int, Int, Int) = (1, 1, 1)) -> Data
```

Executes the kernel on the GPU.

- **Parameters:**
  - `inputs`: Array of input data buffers
  - `gridSize`: Grid dimensions for the kernel execution

- **Returns:** Output data from kernel execution

#### setThreadgroupSize

```swift
func setThreadgroupSize(_ size: (Int, Int, Int))
```

Sets the threadgroup size for kernel execution.

- **Parameters:**
  - `size`: Threadgroup dimensions (default: (256, 1, 1))

## GPUBuffer

Wrapper for GPU memory management.

### Initialization

```swift
init(data: Data, device: MTLDevice)
```

Creates a GPU buffer from CPU data.

### Properties

- `data`: The underlying Metal buffer
- `size`: Size in bytes

## ComputeContext

Manages GPU device and command queue.

### Properties

- `device`: Metal device
- `commandQueue`: Metal command queue
- `library`: Metal function library

### Methods

#### getKernel

```swift
func getKernel(name: String) -> MTLComputePipelineState?
```

Retrieves a compiled kernel from the function library.

## Error Handling

All methods throw `KernelError` on failure:

```swift
enum KernelError: Error {
    case kernelNotFound(String)
    case bufferCreationFailed
    case executionFailed(String)
    case deviceNotAvailable
}
```

## Concurrency

All kernel executions are thread-safe. You can execute multiple kernels concurrently from different threads.
