import Foundation
import Kernels

guard let metalURL = Bundle.module.url(forResource: "kernels", withExtension: "metal") else {
    fatalError("Could not find kernels.metal")
}
let metalSource = try! String(contentsOf: metalURL)

let compute = MetalCompute(metalSource: metalSource)

print("Metal Compute Kernels Demo")
print("==========================\n")

let a: [Float] = [1.0, 2.0, 3.0, 4.0, 5.0]
let b: [Float] = [10.0, 20.0, 30.0, 40.0, 50.0]

print("Array Addition:")
let addResult = compute.arrayAddition(a: a, b: b)
print("  \(a) + \(b) = \(addResult)\n")

print("Array Multiplication:")
let mulResult = compute.arrayMultiply(a: a, b: b)
print("  \(a) * \(b) = \(mulResult)\n")

print("Matrix Multiply (3x3):")
let mat1: [Float] = [1, 2, 3, 4, 5, 6, 7, 8, 9]
let mat2: [Float] = [9, 8, 7, 6, 5, 4, 3, 2, 1]
let matResult = compute.matrixMultiply(a: mat1, b: mat2, size: 3)
print("  Result: \(matResult)\n")

print("Done.")
