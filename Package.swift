// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Kernels",
    platforms: [
        .macOS(.v12),
        .iOS(.v14)
    ],
    products: [
        .library(name: "Kernels", targets: ["Kernels"]),
        .executable(name: "KernelsDemo", targets: ["KernelsDemo"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Kernels",
            dependencies: [],
            path: "Sources/Kernels",
            resources: [
                .copy("kernels.metal")
            ]
        ),
        .executableTarget(
            name: "KernelsDemo",
            dependencies: ["Kernels"],
            path: "Sources/KernelsDemo",
            resources: [
                .copy("kernels.metal")
            ]
        ),
        .testTarget(
            name: "KernelsTests",
            dependencies: ["Kernels"],
            path: "Tests"
        )
    ]
)
