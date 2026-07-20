// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "ExpandoSwift",
    platforms: [.macOS(.v12)],
    products: [
        .executable(name: "expando", targets: ["expando"]),
        .library(name: "ExpandoLib", targets: ["ExpandoLib"]),
    ],
    targets: [
        // Library target containing the core algorithm (testable)
        .target(
            name: "ExpandoLib",
            path: "Sources/ExpandoLib"
        ),
        // Executable target: just the CLI entry point
        .executableTarget(
            name: "expando",
            dependencies: ["ExpandoLib"],
            path: "Sources/expando"
        ),
        // Test target
        .testTarget(
            name: "expandoTests",
            dependencies: ["ExpandoLib"],
            path: "Tests/expandoTests"
        ),
    ]
)
