// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "TubePlayerCore",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "TubePlayerCore", targets: ["TubePlayerCore"])
    ],
    targets: [
        .target(name: "TubePlayerCore"),
        .testTarget(name: "TubePlayerCoreTests", dependencies: ["TubePlayerCore"])
    ]
)
