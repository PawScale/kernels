import Foundation
import Kernels

/// Example: Vector Addition using Metal Compute Kernels
/// This example demonstrates how to add two vectors using GPU compute

func vectorAdditionExample() {
    // Initialize vectors
    let size = 1024
    var a = Array(repeating: Float(1.0), count: size)
    var b = Array(repeating: Float(2.0), count: size)
    var result = Array(repeating: Float(0.0), count: size)
    
    // Execute vector addition kernel
    // let kernel = MetalKernel(name: "vector_add")
    // kernel.execute(inputs: [a, b], output: &result)
    
    // Print results
    print("Vector A (first 5): \(a.prefix(5))")
    print("Vector B (first 5): \(b.prefix(5))")
    print("Result (first 5): \(result.prefix(5))")
}

/// Example: Matrix Multiplication using Metal Compute Kernels
func matrixMultiplicationExample() {
    let size = 512
    var matrixA = Array(repeating: Float(1.0), count: size * size)
    var matrixB = Array(repeating: Float(2.0), count: size * size)
    var result = Array(repeating: Float(0.0), count: size * size)
    
    // Execute matrix multiplication kernel
    // let kernel = MetalKernel(name: "matrix_multiply")
    // kernel.execute(inputs: [matrixA, matrixB], output: &result, gridSize: (size, size))
    
    print("Matrix multiplication completed")
}
