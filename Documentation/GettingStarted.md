# Getting Started with Metal Compute Kernels

## Installation

Add the following to your `Package.swift`:

```swift
.package(url: "https://github.com/PawScale/kernels.git", from: "1.0.0")
```

Then add it as a dependency to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: ["Kernels"]
)
```

## Quick Start

### 1. Write a Metal Kernel

Create a `.metal` file with your compute kernel:

```metal
kernel void vector_add(
    device const float* a [[buffer(0)]],
    device const float* b [[buffer(1)]],
    device float* c [[buffer(2)]],
    uint id [[thread_position_in_grid]]
) {
    c[id] = a[id] + b[id];
}
```

### 2. Load and Execute in Swift

```swift
import Kernels

let kernel = MetalKernel(name: "vector_add")
let result = kernel.execute(inputs: [vectorA, vectorB])
```

## Architecture

The framework provides:

- **MetalKernel**: Main class for loading and executing Metal compute kernels
- **GPUBuffer**: Wrapper for GPU memory management
- **ComputeContext**: GPU device and command queue management

## Performance Tips

1. Batch operations to reduce kernel launch overhead
2. Use appropriate grid and threadgroup sizes
3. Minimize data transfer between CPU and GPU
4. Profile your kernels using Xcode's Metal debugger

## Examples

See the [Examples](../Examples/) directory for complete working examples.

## Troubleshooting

### Kernel not found
Ensure your Metal library is properly bundled and the kernel name matches exactly.

### GPU memory errors
Check that buffer sizes match your kernel's expectations and that you're not exceeding GPU memory limits.

### Performance degradation
Use Xcode's Metal profiler to identify bottlenecks and optimize accordingly.

## Further Reading

- [Apple Metal Documentation](https://developer.apple.com/metal/)
- [CUDA to Metal Translation Guide](../QUICK_REFERENCE.md)
- [Contributing Guide](../CONTRIBUTING.md)
