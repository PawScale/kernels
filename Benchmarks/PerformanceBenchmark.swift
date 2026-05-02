import Foundation
@testable import Kernels

/// Performance benchmarking suite for Metal Compute Kernels
class PerformanceBenchmark {
    
    /// Benchmark vector addition performance
    static func benchmarkVectorAddition(size: Int = 1_000_000) {
        let iterations = 10
        var times: [Double] = []
        
        let a = Array(repeating: Float(1.0), count: size)
        let b = Array(repeating: Float(2.0), count: size)
        
        for _ in 0..<iterations {
            let start = Date()
            // Execute kernel
            _ = vectorAdditionKernel(a, b)
            let elapsed = Date().timeIntervalSince(start)
            times.append(elapsed)
        }
        
        let avgTime = times.reduce(0, +) / Double(times.count)
        let minTime = times.min() ?? 0
        let maxTime = times.max() ?? 0
        
        print("Vector Addition Benchmark (size: \(size))")
        print("  Iterations: \(iterations)")
        print("  Avg time: \(String(format: "%.4f", avgTime)) ms")
        print("  Min time: \(String(format: "%.4f", minTime)) ms")
        print("  Max time: \(String(format: "%.4f", maxTime)) ms")
    }
    
    /// Benchmark matrix multiplication performance
    static func benchmarkMatrixMultiplication(size: Int = 512) {
        let iterations = 5
        var times: [Double] = []
        
        let matrixA = Array(repeating: Float(1.0), count: size * size)
        let matrixB = Array(repeating: Float(2.0), count: size * size)
        
        for _ in 0..<iterations {
            let start = Date()
            // Execute kernel
            _ = matrixMultiplicationKernel(matrixA, matrixB, size: size)
            let elapsed = Date().timeIntervalSince(start)
            times.append(elapsed)
        }
        
        let avgTime = times.reduce(0, +) / Double(times.count)
        
        print("Matrix Multiplication Benchmark (size: \(size)x\(size))")
        print("  Iterations: \(iterations)")
        print("  Avg time: \(String(format: "%.4f", avgTime)) ms")
        print("  GFLOPS: \(calculateGFLOPS(size: size, timeMs: avgTime))")
    }
    
    /// Benchmark memory bandwidth
    static func benchmarkMemoryBandwidth(bufferSizeBytes: Int = 100_000_000) {
        let iterations = 10
        var times: [Double] = []
        
        for _ in 0..<iterations {
            let start = Date()
            // Simulate memory transfer
            let buffer = Array(repeating: Float(1.0), count: bufferSizeBytes / 4)
            let elapsed = Date().timeIntervalSince(start)
            times.append(elapsed)
        }
        
        let avgTime = times.reduce(0, +) / Double(times.count)
        let bandwidthGBps = (Double(bufferSizeBytes) / avgTime) / 1_000_000_000
        
        print("Memory Bandwidth Benchmark (size: \(bufferSizeBytes) bytes)")
        print("  Avg time: \(String(format: "%.4f", avgTime)) ms")
        print("  Bandwidth: \(String(format: "%.2f", bandwidthGBps)) GB/s")
    }
    
    private static func vectorAdditionKernel(_ a: [Float], _ b: [Float]) -> [Float] {
        return zip(a, b).map { $0 + $1 }
    }
    
    private static func matrixMultiplicationKernel(_ a: [Float], _ b: [Float], size: Int) -> [Float] {
        var result = Array(repeating: Float(0.0), count: size * size)
        for i in 0..<size {
            for j in 0..<size {
                var sum = Float(0.0)
                for k in 0..<size {
                    sum += a[i * size + k] * b[k * size + j]
                }
                result[i * size + j] = sum
            }
        }
        return result
    }
    
    private static func calculateGFLOPS(size: Int, timeMs: Double) -> String {
        let flops = Double(2 * size * size * size)
        let gflops = flops / (timeMs / 1000.0) / 1_000_000_000
        return String(format: "%.2f", gflops)
    }
}

// Run benchmarks
PerformanceBenchmark.benchmarkVectorAddition(size: 1_000_000)
PerformanceBenchmark.benchmarkMatrixMultiplication(size: 512)
PerformanceBenchmark.benchmarkMemoryBandwidth()
