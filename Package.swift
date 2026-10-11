// swift-tools-version: 6.1
// The standalone Swift package is in swift/.
// This manifest preserves Swift Package Manager integration from the repository root.

import PackageDescription

let package = Package(
    name: "Handler",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
    ],
    products: [
        .library(name: "Handler", targets: ["Handler"]),
    ],
    targets: [
        .target(
            name: "Handler",
            path: "swift/Sources/Handler"
        ),
        .testTarget(
            name: "HandlerTests",
            dependencies: ["Handler"],
            path: "swift/Tests/HandlerTests"
        ),
    ]
)
